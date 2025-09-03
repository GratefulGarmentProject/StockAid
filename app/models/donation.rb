require "set"

class Donation < ApplicationRecord
  CHANGEABLE_ATTRS = Set.new(%w[external_id journal_external_id]).freeze
  include SoftDeletable

  belongs_to :donor
  belongs_to :user
  belongs_to :revenue_stream
  belongs_to :county, optional: true

  has_many :donation_details, dependent: :destroy
  has_many :donation_program_details, autosave: true, dependent: :destroy

  validate :not_changing_after_closed

  scope :with_includes, -> { includes(:county, :user, donor: :addresses, donation_details: { item: :category }) }
  scope :active_with_includes, -> { active.includes(:county, :user, donor: :addresses, donation_details: { item: :category }) }
  scope :closed_with_includes, -> { closed.includes(:county, :user, donor: :addresses, donation_details: { item: :category }) }
  scope :deleted_with_includes, -> { deleted.includes(:county, :user, donor: :addresses, donation_details: { item: :category }) }

  before_save :set_county_from_donor_county_if_missing

  def self.not_closed
    where(closed_at: nil)
  end

  def self.closed
    where.not(closed_at: nil)
  end

  def self.create_donation!(creator, donor, params)
    donation_params = params.require(:donation).permit(:notes, :date, :revenue_stream_id)

    donation = Donation.create!(
      donor: donor,
      user: creator,
      notes: donation_params[:notes],
      donation_date: donation_params[:date],
      revenue_stream_id: donation_params[:revenue_stream_id]
    )

    donation.add_to_donation!(params, required: true)
    donation
  end

  def closed?
    closed_at.present?
  end

  def close
    raise "Donation cannot be closed until donor is synced" unless donor.synced?

    transaction do
      create_values_for_programs
      self.closed_at = Time.zone.now
      NetSuiteIntegration::DonationExporter.new(self).export_later
      save!
    end
  end

  def zero_affected_items?
    donation_details.all? { |x| x.quantity == 0 } && donation_program_details.all? { |x| x.value == 0 }
  end

  def soft_delete_closed
    transaction do
      reload
      raise "Donation is not closed" unless closed?
      raise "Donation is already deleted" if zero_affected_items?

      @allow_change_after_closed = true
      note_message = "This donation was deleted after being closed at #{Time.zone.now.strftime("%m/%d/%Y %H:%M%P")}"

      begin
        if notes.present?
          self.notes += "\n\n#{note_message}"
        else
          self.notes = note_message
        end

        donation_details.each(&:soft_delete_closed)
        donation_program_details.each(&:soft_delete_closed)
        save!
      ensure
        @allow_change_after_closed = false
      end
    end
  end

  def update_donation!(params)
    donation_params = params.require(:donation).permit(:notes, :date, :revenue_stream_id)
    self.notes = donation_params[:notes]
    self.donation_date = donation_params[:date]
    self.revenue_stream_id = donation_params[:revenue_stream_id]
    save!
    add_to_donation!(params)
    self
  end

  def sync_status_available?
    external_id.present?
  end

  def journal_sync_status_available?
    journal_external_id.present?
  end

  def can_be_synced?(syncing_now: false)
    if syncing_now
      closed? && donor.synced? && NetSuiteIntegration.any_not_exported_successfully?(self, additional_prefixes: :journal)
    else
      closed? && donor.synced? && (!synced? || !journal_synced?)
    end
  end

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
  end

  def journal_synced?
    journal_external_id.present? && !NetSuiteIntegration.export_failed?(self, prefix: :journal)
  end

  def formatted_donation_date
    donation_date.strftime("%-m/%-d/%Y") if donation_date.present?
  end

  def value
    donation_details.map(&:total_value).sum
  end

  def item_count
    donation_details.map(&:quantity).sum
  end

  def create_values_for_programs
    transaction do
      program_values = Hash.new { |h, k| h[k] = 0.0 }

      donation_details.each do |detail|
        ratios = detail.item.program_ratio_split_for(detail.item.programs)

        ratios.each do |program, ratio|
          program_values[program] += detail.total_value * ratio
        end
      end

      program_values.each do |program, value|
        donation_program_details.create!(program: program, value: value)
      end
    end
  end

  def value_by_program
    donation_program_details.all.each_with_object({}) do |detail, result|
      result[detail.program] = detail.value
      result
    end
  end

  def add_to_donation!(params, required: false)
    return self if skip_adding_donations?(params, required)
    donation_detail_params = params.require(:donation).require(:donation_details)
    item_params = donation_detail_params.require(:item_id)
    quantity_params = donation_detail_params.require(:quantity)

    item_params.each_with_index do |item_id, i|
      quantity = quantity_params[i].to_i
      item = Item.find(item_id)

      donation_details.create!(
        item: item,
        quantity: quantity,
        value: item.value
      )
    end
  end

  private

  def skip_adding_donations?(params, required)
    return false if required
    return true if params.dig(:donation, :donation_details, :item_id).blank?
    false
  end

  def not_changing_after_closed
    return if @allow_change_after_closed
    return if closed_at_was.nil?
    # Changing nothing won't really have any affect on the closed donation
    return if changed == []
    # Allow changing external id later, otherwise syncing to NetSuite will fail
    return if changed.all? { |attr| CHANGEABLE_ATTRS.include?(attr) }
    errors.add(:base, "cannot change a closed donation!")
  end

  def set_county_from_donor_county_if_missing
    return if county_id.present?

    self.county_id = donor.county_id
  end
end

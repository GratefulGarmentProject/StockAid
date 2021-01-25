class Donation < ApplicationRecord
  include SoftDeletable

  belongs_to :donor
  belongs_to :user
  has_many :donation_details
  has_many :donation_program_details, autosave: true

  validate :not_changing_after_closed

  def self.not_closed
    where(closed_at: nil)
  end

  def self.closed
    where.not(closed_at: nil)
  end

  def self.create_donation!(creator, params)
    donor = Donor.create_or_find_donor(params)
    donation_params = params.require(:donation).permit(:notes, :date)

    donation = Donation.create!(
      donor: donor,
      user: creator,
      notes: donation_params[:notes],
      donation_date: donation_params[:date]
    )

    donation.add_to_donation!(params, required: true)
    donation
  end

  def closed?
    closed_at.present?
  end

  def close
    transaction do
      create_values_for_programs
      self.closed_at = Time.zone.now
      save!
    end
  end

  def update_donation!(params)
    donation_params = params.require(:donation).permit(:notes, :date)
    self.notes = donation_params[:notes]
    self.donation_date = donation_params[:date]
    save!
    add_to_donation!(params)
    self
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
    return if closed_at_was.nil?
    errors.add(:base, "cannot change a closed donation!")
  end
end

class Purchase < ApplicationRecord
  include ActiveSupport::NumberHelper
  include PurchaseStatus

  belongs_to :user
  belongs_to :vendor

  has_many :purchase_details, autosave: true, dependent: :restrict_with_exception
  has_many :purchase_program_details, autosave: true, dependent: :destroy
  has_many :purchase_shipments, through: :purchase_details, dependent: :restrict_with_exception
  has_many :items, through: :purchase_details

  has_many :revenue_stream_purchases
  has_many :revenue_streams, through: :revenue_stream_purchases

  accepts_nested_attributes_for :purchase_details, allow_destroy: true

  before_validation :set_new_status, on: :create

  validates :user, presence: true
  validates :vendor, presence: true
  validates :purchase_date, presence: true
  validates :status, presence: true

  alias_attribute :details, :purchase_details
  alias_attribute :shipments, :purchase_shipments

  def self.for_vendor(vendor)
    where(vendor: vendor)
  end

  def fully_received?
    purchase_details.all?(&:fully_received?)
  end

  def sync_status_available?
    external_id.present?
  end

  def variance_sync_status_available?
    variance_external_id.present?
  end

  def can_be_synced?(syncing_now: false)
    if syncing_now
      closed? && (!NetSuiteIntegration.exported_successfully?(self) || !NetSuiteIntegration.exported_successfully?(self, prefix: :variance))
    else
      closed? && (!synced? || !ppv_synced?)
    end
  end

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
  end

  def ppv_synced?
    variance_external_id.present? && !NetSuiteIntegration.export_failed?(self, prefix: :variance)
  end

  def formatted_purchase_date
    purchase_date&.strftime("%-m/%-d/%Y")
  end

  def cost
    purchase_details.map(&:line_cost).sum
  end

  def display_cost
    number_to_currency(cost || 0)
  end

  def display_total
    total = (cost || 0) + (tax || 0) + (shipping_cost || 0)
    number_to_currency(total)
  end

  def item_count
    purchase_details.map(&:quantity).sum
  end

  def readable_status
    readable_status = status.split("_").map(&:capitalize).join(" ")
    readable_status += " (saved)" if new_purchase? && persisted?
    readable_status
  end

  def display_total_ppv
    number_to_currency(total_ppv)
  end

  def total_ppv
    purchase_details.map { |pd| pd.variance * pd.quantity }.sum
  end

  def create_values_for_programs
    transaction do
      program_values = Hash.new { |h, k| h[k] = 0.0 }

      purchase_details.each do |detail|
        ratios = detail.item.program_ratio_split_for(detail.item.programs)

        ratios.each do |program, ratio|
          program_values[program] += detail.line_cost * ratio
        end
      end

      program_values.each do |program, value|
        purchase_program_details.create!(program: program, value: value)
      end
    end
  end

  def value_by_program
    purchase_program_details.all.each_with_object({}) do |detail, result|
      result[detail.program] = detail.value
      result
    end
  end

  private

  def set_new_status
    self.status = :new_purchase if status.blank?
  end
end

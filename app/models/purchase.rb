class Purchase < ApplicationRecord
  include ActiveSupport::NumberHelper
  include PurchaseStatus

  belongs_to :user
  belongs_to :vendor

  has_many :purchase_details, autosave: true, dependent: :restrict_with_exception
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

  def total_ppv
    purchase_details.map { |pd| pd.variance * pd.quantity }.sum
  end

  private

  def set_new_status
    self.status = :new_purchase if status.blank?
  end
end

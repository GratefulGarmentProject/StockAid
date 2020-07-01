class Purchase < ApplicationRecord
  include PurchaseStatus

  attribute :open_purchase?, :boolean

  belongs_to :user
  belongs_to :vendor
  belongs_to :vendor_unscoped, -> { unscope(:where) }, class_name: "Vendor", foreign_key: :vendor_id

  has_many :purchase_details, autosave: true, dependent: :restrict_with_exception
  has_many :purchase_shipments, through: :purchase_details, dependent: :restrict_with_exception
  has_many :items, through: :purchase_details

  accepts_nested_attributes_for :purchase_details, allow_destroy: true

  before_validation :set_new_status, on: :create

  validates :user, presence: true
  validates :vendor, presence: true

  validates :purchase_date, presence: true
  validates :status, presence: true

  def self.for_vendor(vendor)
    where(vendor: vendor)
  end

  def formatted_purchase_date
    purchase_date&.strftime("%-m/%-d/%Y")
  end

  def cost
    purchase_details.map(&:line_cost).sum
  end

  def item_count
    purchase_details.map(&:quantity).sum
  end

  def readable_status
    readable_status = status.split("_").map(&:capitalize).join(" ")
    readable_status += " (saved)" if new_purchase? && persisted?
    readable_status
  end

  private

  def set_new_status
    self.status = :new_purchase if status.blank?
  end
end

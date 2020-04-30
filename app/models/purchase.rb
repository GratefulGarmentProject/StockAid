class Purchase < ApplicationRecord
  include PurchaseStatus

  belongs_to :user
  belongs_to :vendor
  belongs_to :vendor_unscoped, -> { unscope(:where) }, class_name: "Vendor", foreign_key: :vendor_id

  has_many :purchase_details, autosave: true
  has_many :items, through: :order_details
  accepts_nested_attributes_for :purchase_details

  before_validation :set_new_status, on: :create
  before_save :prevent_updates_when_closed, on: :update

  validates :po, presence: true
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

  def to_json
    attributes.merge(
      user: user.as_json,
      vendor: vendor.as_json,
      purchase_details: purchase_details.order(id: :asc).map(&:as_json)
    ).to_json
  end

  private

  def prevent_updates_when_closed
    return unless closed? || canceled?
    unless changed.include?("status")
      msg = "Can't modify purchase after it's closed or canceled"
      restore_attributes
      raise msg
    end
  end

  def skip_adding_purchase_details?
    return true if valid_purchase_params.dig(:purchase_details, :item_id).blank?
    false
  end

  def set_new_status
    self.status = :new_purchase if status.blank?
  end
end

class Purchase < ApplicationRecord
  include PurchaseStatus

  belongs_to :user
  belongs_to :vendor
  belongs_to :vendor_unscoped, -> { unscope(:where) }, class_name: "Vendor", foreign_key: :vendor_id

  has_many :purchase_details
  accepts_nested_attributes_for :purchase_details

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

  private

  def skip_adding_purchase_details?
    return true if valid_purchase_params.dig(:purchase_details, :item_id).blank?
    false
  end
end

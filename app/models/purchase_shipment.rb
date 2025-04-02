class PurchaseShipment < ApplicationRecord
  belongs_to :purchase_detail, optional: true

  before_validation :set_received_date

  validates :received_date, presence: true
  validates :quantity_received, presence: true, numericality: { only_integer: true, greater_than: 0 }

  after_create :add_to_inventory
  before_destroy :subtract_from_inventory

  def add_to_inventory
    purchase_detail.item.mark_event(
      edit_amount: quantity_received,
      edit_method: "add",
      edit_reason: "purchase_shipment_received",
      edit_source: item_edit_source
    )
    purchase_detail.item.save!
  end

  def subtract_from_inventory
    purchase_detail.item.mark_event(
      edit_amount: quantity_received,
      edit_method: "subtract",
      edit_reason: "purchase_shipment_deleted",
      edit_source: item_edit_source
    )
    purchase_detail.item.save!
  end

  private

  def item_edit_source
    po_number = purchase_detail&.purchase&.vendor_po_number
    "Purchase PO ##{po_number}, Purchase Detail id ##{purchase_detail_id}, Purchase id ##{purchase_detail.purchase_id}"
  end

  def set_received_date
    self.received_date = Time.zone.today if received_date.blank?
  end
end

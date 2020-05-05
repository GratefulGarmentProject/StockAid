class PurchaseShipment < ApplicationRecord
  belongs_to :purchase_detail, optional: true

  before_validation :set_received_at

  validates :received_at, presence: true
  validates :quantity_received, presence: true, numericality: { only_integer: true, greater_than: 0 }

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
      edit_reason: "purchase_shipment_returned",
      edit_source: item_edit_source
    )
    purchase_detail.item.save!
  end

  private

  def item_edit_source
    "Purchase PO ##{purchase_detail&.purchase&.po} Line item ##{purchase_detail_id}"
  end

  def set_received_at
    self.received_at = Time.current unless received_at.present?
  end
end

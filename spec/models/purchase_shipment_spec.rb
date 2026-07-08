require "rails_helper"

describe PurchaseShipment, type: :model do
  let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail) }
  let(:item) { items(:small_flip_flops) }

  describe "#add_to_inventory (after_create)" do
    it "increases the item's current_quantity when a shipment is created" do
      original_qty = item.current_quantity

      shipment = purchase_detail.purchase_shipments.create!(
        quantity_received: 5
      )

      item.reload
      expect(item.current_quantity).to eq(original_qty + 5)
    end
  end

  describe "#subtract_from_inventory (before_destroy)" do
    it "decreases the item's current_quantity when a shipment is destroyed" do
      shipment = purchase_detail.purchase_shipments.create!(quantity_received: 3)
      item.reload
      qty_after_create = item.current_quantity

      shipment.destroy

      item.reload
      expect(item.current_quantity).to eq(qty_after_create - 3)
    end
  end
end

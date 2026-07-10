require "rails_helper"

RSpec.describe PurchasesHelper, type: :helper do
  let(:vendor_synced) { vendors(:guinan).tap { |v| v.update_column(:external_id, 99) } }
  let(:vendor_unsynced) { vendors(:guinan).tap { |v| v.update_column(:external_id, nil) } }

  describe "#cancel_edit_purchase_path" do
    it "returns purchases_path when no redirect_to param" do
      expect(helper.cancel_edit_purchase_path).to eq(purchases_path)
    end
  end

  describe "#cancel_new_purchase_path" do
    it "returns purchases_path when no redirect_to param" do
      expect(helper.cancel_new_purchase_path).to eq(purchases_path)
    end
  end

  describe "#purchase_detail_quantity_class" do
    it "returns same-quantity when equal" do
      detail = double(quantity: 5, requested_quantity: 5)
      expect(helper.purchase_detail_quantity_class(detail)).to eq("same-quantity")
    end

    it "returns more-quantity when quantity exceeds requested" do
      detail = double(quantity: 7, requested_quantity: 5)
      expect(helper.purchase_detail_quantity_class(detail)).to eq("different-quantity more-quantity")
    end

    it "returns less-quantity when quantity is below requested" do
      detail = double(quantity: 3, requested_quantity: 5)
      expect(helper.purchase_detail_quantity_class(detail)).to eq("different-quantity less-quantity")
    end
  end

  describe "#sync_purchase_button" do
    let(:purchase_synced_vendor) do
      purchase = purchases(:new_purchase_with_details)
      purchase.vendor.update_column(:external_id, 99)
      purchase
    end

    let(:purchase_unsynced_vendor) do
      purchase = purchases(:new_purchase_with_details)
      purchase.vendor.update_column(:external_id, nil)
      purchase
    end

    it "renders a link without disabled class for synced vendor" do
      html = helper.sync_purchase_button(purchase_synced_vendor)
      expect(html).to include("Sync to NetSuite")
      expect(html).not_to include("disabled")
    end

    it "wraps button with disabled tooltip for unsynced vendor" do
      html = helper.sync_purchase_button(purchase_unsynced_vendor)
      expect(html).to include("Please sync the vendor")
    end
  end

  describe "#close_purchase_button" do
    let(:received_purchase) do
      purchase = purchases(:received_purchase)
      purchase.vendor.update_column(:external_id, 99)
      purchase
    end

    let(:received_purchase_unsynced) do
      purchase = purchases(:received_purchase)
      purchase.vendor.update_column(:external_id, nil)
      purchase
    end

    it "renders button for synced vendor" do
      html = helper.close_purchase_button(received_purchase)
      expect(html).to include("Close Purchase")
    end

    it "wraps button with disabled tooltip for unsynced vendor" do
      html = helper.close_purchase_button(received_purchase_unsynced)
      expect(html).to include("Please sync the vendor to be able to close.")
    end
  end

  describe "#receive_purchase_button" do
    let(:fully_received_purchase) do
      purchase = purchases(:purchase_with_details_and_shipments)
      allow(purchase).to receive(:fully_received?).and_return(true)
      purchase
    end

    let(:not_fully_received_purchase) do
      purchase = purchases(:purchase_with_details_and_shipments)
      allow(purchase).to receive(:fully_received?).and_return(false)
      purchase
    end

    it "renders enabled button when fully received" do
      html = helper.receive_purchase_button(fully_received_purchase)
      expect(html).to include("Purchase Received")
      expect(html).not_to include("disabled")
    end

    it "renders disabled tooltip when not fully received" do
      html = helper.receive_purchase_button(not_fully_received_purchase)
      expect(html).to include("Please finish marking the items received")
    end
  end

  describe "#purchase_detail_with_shipments_delete_button (via link_to_remove_purchase_association_row)" do
    it "renders disabled button when purchase detail has shipments" do
      detail = purchase_details(:small_flip_flops_purchase_detail_with_shipments)
      html = helper.link_to_remove_purchase_association_row(detail)
      expect(html).to include("disabled")
      expect(html).to include("Disabled: Shipments exist!")
    end

    it "renders persisted delete button for detail without shipments" do
      detail = purchase_details(:small_flip_flops_purchase_detail)
      html = helper.link_to_remove_purchase_association_row(detail)
      expect(html).to include("btn-danger")
    end
  end

  describe "#purchase_shipment_confirm" do
    it "returns persisted dialog message for a persisted shipment" do
      shipment = purchase_shipments(:small_flip_flops_partial_shipment_one)
      result = helper.send(:purchase_shipment_confirm, shipment)
      expect(result).to be_a(String)
      expect(result).to be_present
    end

    it "returns non-persisted dialog message for a new shipment" do
      shipment = PurchaseShipment.new
      result = helper.send(:purchase_shipment_confirm, shipment)
      expect(result).to be_a(String)
    end
  end

  describe "#purchase_short_confirm" do
    it "returns a confirmation message" do
      result = helper.send(:purchase_short_confirm, nil)
      expect(result).to be_a(String)
    end
  end

  describe "#link_to_remove_purchase_association_row with new record" do
    it "renders a non-persisted delete button for a new purchase_detail" do
      detail = PurchaseDetail.new
      html = helper.link_to_remove_purchase_association_row(detail)
      expect(html).to include("btn-danger")
      expect(html).to include("remove-purchase-detail-fields")
    end
  end

  describe "#vendor_options" do
    it "returns an array of vendor name/id pairs with data attributes" do
      options = helper.vendor_options
      expect(options).to be_an(Array)
      expect(options.first).to be_an(Array)
    end
  end

  describe "#purchase_row_item_options" do
    it "returns empty array when detail has no item" do
      detail = double(item: nil)
      expect(helper.purchase_row_item_options(detail)).to eq([])
    end

    it "returns options based on the item's category when item is present" do
      detail = purchase_details(:small_flip_flops_purchase_detail)
      result = helper.purchase_row_item_options(detail)
      expect(result).to be_present
    end
  end
end

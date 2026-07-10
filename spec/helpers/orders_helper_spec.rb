require "rails_helper"

RSpec.describe OrdersHelper, type: :helper do
  describe "#order_has_tracking_details?" do
    it "returns true when order has no tracking details" do
      order = orders(:open_order)
      expect(helper.order_has_tracking_details?(order)).to eq(true)
    end
  end

  describe "#cancel_edit_order_path" do
    it "returns orders_path when no redirect_to param" do
      expect(helper.cancel_edit_order_path).to eq(orders_path)
    end
  end

  describe "#cancel_new_order_path" do
    it "returns orders_path when no redirect_to param" do
      expect(helper.cancel_new_order_path).to eq(orders_path)
    end
  end

  describe "#order_detail_quantity_class" do
    it "returns same-quantity when equal" do
      detail = double(quantity: 5, requested_quantity: 5)
      expect(helper.order_detail_quantity_class(detail)).to eq("same-quantity")
    end

    it "returns more-quantity when quantity exceeds requested" do
      detail = double(quantity: 7, requested_quantity: 5)
      expect(helper.order_detail_quantity_class(detail)).to eq("different-quantity more-quantity")
    end

    it "returns less-quantity when quantity is below requested" do
      detail = double(quantity: 3, requested_quantity: 5)
      expect(helper.order_detail_quantity_class(detail)).to eq("different-quantity less-quantity")
    end
  end

  describe "#sync_order_button" do
    let(:synced_org_order) do
      order = orders(:open_order)
      allow(order.organization).to receive(:synced?).and_return(true)
      order
    end

    let(:unsynced_org_order) do
      order = orders(:open_order)
      allow(order.organization).to receive(:synced?).and_return(false)
      order
    end

    it "renders link without disabled for synced org" do
      html = helper.sync_order_button(synced_org_order)
      expect(html).to include("Sync to NetSuite")
      expect(html).not_to include("Please sync the organization")
    end

    it "wraps with tooltip for unsynced org" do
      html = helper.sync_order_button(unsynced_org_order)
      expect(html).to include("Please sync the organization to be able to sync to NetSuite.")
    end
  end

  describe "#close_order_button" do
    let(:synced_org_order) do
      order = orders(:open_order)
      allow(order.organization).to receive(:synced?).and_return(true)
      order
    end

    let(:unsynced_org_order) do
      order = orders(:open_order)
      allow(order.organization).to receive(:synced?).and_return(false)
      order
    end

    it "renders close button for synced org" do
      html = helper.close_order_button(synced_org_order)
      expect(html).to include("Close Order")
    end

    it "wraps with tooltip for unsynced org" do
      html = helper.close_order_button(unsynced_org_order)
      expect(html).to include("Please sync the organization to NetSuite to be able to close this order.")
    end
  end

  describe "#show_cancel_button?" do
    let(:user) { users(:root) }

    it "returns false for a new (unsaved) order" do
      order = Order.new
      expect(helper.show_cancel_button?(order, user)).to eq(false)
    end

    it "returns false for a canceled order" do
      order = orders(:closed_order)
      allow(order).to receive(:canceled?).and_return(true)
      expect(helper.show_cancel_button?(order, user)).to eq(false)
    end

    it "returns true for an editable order when user can cancel" do
      order = orders(:open_order)
      expect(helper.show_cancel_button?(order, user)).to eq(true)
    end
  end

  describe "#cancel_order_confirm" do
    it "returns confirm options without message for unsynced order" do
      order = orders(:open_order)
      allow(order).to receive(:synced?).and_return(false)
      result = helper.cancel_order_confirm(order)
      expect(result).to be_a(Hash)
    end

    it "includes message for synced order" do
      order = orders(:open_order)
      allow(order).to receive(:synced?).and_return(true)
      result = helper.cancel_order_confirm(order)
      expect(result.to_s).to include("NOT")
    end
  end
end

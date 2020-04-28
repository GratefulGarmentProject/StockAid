require "rails_helper"

RSpec.describe Purchase do
  describe "#update" do
    context "when purchase is in closed status" do
      let(:purchase) { purchases(:new_purchase_with_details) }
      it "should not update purchase in closed state" do
        # walk the purchase through the steps
        purchase.place_purchase!
        purchase.ship_purchase!
        purchase.receive_purchase!
        purchase.complete_purchase!
        old_shipping = purchase.shipping_cost
        aggregate_failures do
          expect {
            purchase.update(shipping_cost: 1.25)
          }.to raise_error(RuntimeError, "Can't modify purchase after it's closed or canceled")
          expect(purchase.shipping_cost).to eq(old_shipping)
        end
      end
    end

    context "when purchase is in purchased status" do
      let(:purchase) { purchases(:new_purchase_with_details) }
      it "should not update purchase in canceled state" do
        # walk the purchase through the steps
        purchase.place_purchase!
        purchase.cancel_purchase!
        old_shipping = purchase.shipping_cost
        aggregate_failures do
          expect {
            purchase.update(shipping_cost: 1.25)
          }.to raise_error(RuntimeError, "Can't modify purchase after it's closed or canceled")
          expect(purchase.shipping_cost).to eq(old_shipping)
        end
      end

    end
  end
end

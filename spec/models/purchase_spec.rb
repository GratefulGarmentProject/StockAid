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
          expect { purchase.update(shipping_cost: 1.25) }
            .to(raise_error(RuntimeError, "Can't modify purchase after it's closed or canceled"))
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
          expect { purchase.update(shipping_cost: 1.25) }
            .to raise_error(RuntimeError, "Can't modify purchase after it's closed or canceled")
          expect(purchase.shipping_cost).to eq(old_shipping)
        end
      end
    end

    context "when purchase has purchase details and partial shipments" do
      let!(:purchase) { purchases(:new_purchase_with_details_and_shipments) }
      it "will not let the purchase be destroyed" do
        expect { purchase.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
      it "will not let the purchase details be destroyed" do
        expect { purchase.purchase_details.first.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
      it "will let purchase_detail be destroyed when all purchase shipments have been destroyed" do
        pd = purchase.purchase_details.first
        pd_id = pd.id
        pd.purchase_shipments.destroy_all
        pd.reload
        expect(pd.destroy).to be_truthy
        expect { PurchaseDetail.find(pd_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it "will let purchase be destroyed when all purchase details (and shipments) have been destroyed" do
        p_id = purchase.id
        purchase.purchase_details.each do |pd|
          pd.purchase_shipments.destroy_all
          pd.destroy
        end
        purchase.reload
        expect(purchase.destroy).to be_truthy
        expect { Purchase.find(p_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

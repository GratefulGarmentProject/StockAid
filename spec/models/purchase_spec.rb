require "rails_helper"

RSpec.describe Purchase do
  describe "#update" do
    context "when purchase has purchase details and partial shipments" do
      let!(:purchase) { purchases(:purchase_with_details_and_shipments) }

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

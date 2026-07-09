require "rails_helper"

RSpec.describe Purchase do
  let(:received) { purchases(:received_purchase) }

  describe ".for_vendor" do
    it "returns purchases for the given vendor" do
      results = Purchase.for_vendor(vendors(:guinan))
      expect(results).to include(received)
    end
  end

  describe "#fully_received?" do
    it "returns false when no details are fully received" do
      expect(received.fully_received?).to be false
    end
  end

  describe "#item_count" do
    it "returns the sum of quantities across all purchase details" do
      expect(received.item_count).to eq(16)
    end
  end

  describe "#ppv_synced?" do
    it "returns false when variance_external_id is nil" do
      expect(received.ppv_synced?).to be false
    end

    it "returns true when variance_external_id is set and not failed" do
      received.update_column(:variance_external_id, 99)
      expect(received.ppv_synced?).to be true
    end
  end

  describe "#display_total_ppv" do
    it "returns a formatted currency string" do
      result = received.display_total_ppv
      expect(result).to be_a(String)
      expect(result).to match(/\$/)
    end
  end

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

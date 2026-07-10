require "rails_helper"

describe Organization, type: :model do
  describe ".find_any" do
    it "finds a deleted organization by id" do
      org = organizations(:no_order_org)
      org.soft_delete
      expect(Organization.find_any(org.id)).to eq(org)
    end
  end

  describe "#sync_status_available?" do
    it "returns true when external_id is present" do
      org = organizations(:acme)
      org.external_id = 12345
      expect(org.sync_status_available?).to be true
    end

    it "returns false when external_id is blank" do
      org = organizations(:acme)
      org.external_id = nil
      expect(org.sync_status_available?).to be false
    end
  end

  describe "#synced?" do
    it "returns false when external_id is blank" do
      org = organizations(:acme)
      org.external_id = nil
      expect(org.synced?).to be false
    end

    it "returns true when external_id present and no export failure" do
      org = organizations(:acme)
      org.external_id = 9999
      allow(NetSuiteIntegration).to receive(:export_failed?).with(org).and_return(false)
      expect(org.synced?).to be true
    end
  end

  describe ".counties" do
    it "returns unique county values" do
      result = Organization.counties
      expect(result).to be_an(Array)
    end
  end
end

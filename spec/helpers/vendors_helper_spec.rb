require "rails_helper"

RSpec.describe VendorsHelper, type: :helper do
  describe "#save_vendor_path" do
    it "returns the vendors path" do
      expect(helper.save_vendor_path).to eq(vendors_path)
    end
  end

  describe "#cancel_edit_vendor_path" do
    it "returns the vendors path" do
      expect(helper.cancel_edit_vendor_path).to eq(vendors_path)
    end
  end

  describe "#cancel_new_vendor_path" do
    it "returns the vendors path" do
      expect(helper.cancel_new_vendor_path).to eq(vendors_path)
    end
  end
end

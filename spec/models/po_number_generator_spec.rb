require "rails_helper"

RSpec.describe PoNumberGenerator do
  context "when no vendor provided" do
    it "returns a default string" do
      expect(PoNumberGenerator.new(0).generate).to eq("UNKNOW-000000")
    end
  end
  context "when vendor provided" do
    let!(:vendor) { Vendor.create(name: "Garek's Fine Clothing and Tailoring") }

    context "when no purchases for vendor" do
      it "returns the first number for that vendor" do
        expect(PoNumberGenerator.new(vendor.id).generate).to eq("GAREKS-000001")
      end
    end

    context "when multiple purchases for vendor" do
      let!(:user) do
        User.create(
          email: "test@fake.com",
          name: "test user",
          primary_number: "555-1212",
          password: "P4ssword"
        )
      end
      before do
        10.times do |x|
          Purchase.create(
            user: user,
            vendor: vendor,
            po: PoNumberGenerator.new(vendor.id).format_string(vendor.name.parameterize, x),
            purchase_date: 1.day.ago
          )
        end
      end
      it "returns the next PO number in sequence" do
        expect(PoNumberGenerator.new(vendor.id).generate).to match(/\AGAREKS-\d+\z/)
      end
    end
  end
end

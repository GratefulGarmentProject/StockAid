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
            po: PoNumberGenerator.new(vendor.id).format_string(vendor.name.parameterize, x + 1),
            purchase_date: 1.day.ago
          )
        end
      end
      it "returns the next PO number in sequence" do
        new_po_number = PoNumberGenerator.new(vendor.id).generate
        expect(new_po_number).to match(/\AGAREKS-\d+\z/)
        digits = new_po_number.split("-").last
        expect(digits.to_i).to eq(11)
      end
    end
    context "when none of the previous purchases PO numbers has a digits part" do
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
            po: "PONUM#{'*' * x}",
            purchase_date: 1.day.ago
          )
        end
      end
      it "returns the next PO number with a digits part" do
        new_po_number = PoNumberGenerator.new(vendor.id).generate
        expect(new_po_number).to match(/\AGAREKS-\d+\z/)
        digits = new_po_number.split("-").last
        expect(digits.to_i).to eq(1), digits
      end
    end
  end
end

require "rails_helper"

describe NetSuiteIntegration::VendorImporter, type: :model do
  let(:netsuite_vendor_double) do
    double(
      :netsuite_vendor,
      name: "Imported Vendor Co",
      netsuite_id: 700,
      type: "Company",
      email: "vendor@imported.com",
      phone: "(408) 555-7777",
      address: nil
    )
  end

  let(:params) { ActionController::Parameters.new(external_id: "700") }

  before do
    allow(NetSuiteIntegration::NetSuiteVendor).to receive(:by_id).with(700).and_return(netsuite_vendor_double)
  end

  describe "#import" do
    it "creates a new vendor from NetSuite data" do
      importer = described_class.new(params)
      expect { importer.import }.to change(Vendor, :count).by(1)
    end

    it "sets the correct attributes on the new vendor" do
      importer = described_class.new(params)
      vendor = importer.import
      expect(vendor.name).to eq("Imported Vendor Co")
      expect(vendor.external_id).to eq(700)
      expect(vendor.external_type).to eq("Company")
    end

    it "builds address when vendor has an address" do
      allow(netsuite_vendor_double).to receive(:address).and_return(
        street_address: "789 Vendor Blvd", city: "Fremont", state: "CA", zip: "94536"
      )
      importer = described_class.new(params)
      vendor = importer.import
      expect(vendor.addresses.count).to eq(1)
    end

    context "when the vendor is not found in NetSuite" do
      before do
        allow(NetSuiteIntegration::NetSuiteVendor).to receive(:by_id).and_raise(NetSuite::RecordNotFound)
      end

      it "raises ActiveRecord::RecordInvalid" do
        importer = described_class.new(params)
        expect { importer.import }.to raise_error(ActiveRecord::RecordInvalid, /Could not find NetSuite Vendor/)
      end
    end
  end
end

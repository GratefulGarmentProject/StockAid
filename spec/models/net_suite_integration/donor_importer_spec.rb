require "rails_helper"

describe NetSuiteIntegration::DonorImporter, type: :model do
  let(:constituent_double) do
    double(
      :constituent,
      donor?: true,
      organization?: false,
      name: "New Imported Donor",
      netsuite_id: 500,
      type: "Individual",
      email: "imported@example.com",
      phone: "(408) 555-5555",
      address: nil
    )
  end

  let(:params) { ActionController::Parameters.new(external_id: "500") }

  before do
    allow(NetSuiteIntegration::Constituent).to receive(:by_id).with(500).and_return(constituent_double)
  end

  describe "#import" do
    it "creates a new donor from the NetSuite constituent" do
      importer = described_class.new(params)
      expect { importer.import }.to change(Donor, :count).by(1)
    end

    it "sets the correct attributes on the new donor" do
      importer = described_class.new(params)
      donor = importer.import
      expect(donor.name).to eq("New Imported Donor")
      expect(donor.external_id).to eq(500)
      expect(donor.external_type).to eq("Individual")
      expect(donor.email).to eq("imported@example.com")
    end

    it "builds address when constituent has an address" do
      allow(constituent_double).to receive(:address).and_return(
        street_address: "123 Main St", city: "San Jose", state: "CA", zip: "95101"
      )
      importer = described_class.new(params)
      donor = importer.import
      expect(donor.addresses.count).to eq(1)
    end

    context "when the constituent is not found in NetSuite" do
      before do
        allow(NetSuiteIntegration::Constituent).to receive(:by_id).and_raise(NetSuite::RecordNotFound)
      end

      it "raises ActiveRecord::RecordInvalid" do
        importer = described_class.new(params)
        expect { importer.import }.to raise_error(ActiveRecord::RecordInvalid, /Could not find NetSuite Constituent/)
      end
    end

    context "when the constituent is not a donor" do
      before { allow(constituent_double).to receive(:donor?).and_return(false) }

      it "raises ActiveRecord::RecordInvalid" do
        allow(constituent_double).to receive(:netsuite_id).and_return(500)
        importer = described_class.new(params)
        expect { importer.import }.to raise_error(ActiveRecord::RecordInvalid, /is not a donor/)
      end
    end
  end
end

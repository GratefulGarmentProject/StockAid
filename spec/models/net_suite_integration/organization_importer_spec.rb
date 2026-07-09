require "rails_helper"

describe NetSuiteIntegration::OrganizationImporter, type: :model do
  let(:constituent_double) do
    double(
      :constituent,
      donor?: false,
      organization?: true,
      name: "Imported Org",
      netsuite_id: 600,
      type: "Agency",
      email: "info@importedorg.com",
      phone: "(408) 555-6666",
      address: nil,
      county_id: nil,
      county_name: nil
    )
  end

  let(:params) do
    ActionController::Parameters.new(
      external_id: "600",
      organization: { program_ids: [programs(:resource_closets).id] }
    )
  end

  before do
    allow(NetSuiteIntegration::Constituent).to receive(:by_id).with(600).and_return(constituent_double)
  end

  describe "#import" do
    it "creates a new organization from the NetSuite constituent" do
      importer = described_class.new(params)
      expect { importer.import }.to change(Organization, :count).by(1)
    end

    it "sets the correct attributes on the new organization" do
      importer = described_class.new(params)
      org = importer.import
      expect(org.name).to eq("Imported Org")
      expect(org.external_id).to eq(600)
      expect(org.external_type).to eq("Agency")
    end

    it "builds address when constituent has an address" do
      allow(constituent_double).to receive(:address).and_return(
        street_address: "456 Org St", city: "Oakland", state: "CA", zip: "94601"
      )
      importer = described_class.new(params)
      org = importer.import
      expect(org.addresses.count).to eq(1)
    end

    context "when the county_id is present and county exists in DB" do
      before do
        allow(constituent_double).to receive(:county_id).and_return(counties(:santa_clara).external_id.to_s)
        allow(constituent_double).to receive(:county_name).and_return("California : Santa Clara County")
      end

      it "assigns the existing county to the organization" do
        importer = described_class.new(params)
        org = importer.import
        expect(org.organization_county).to eq(counties(:santa_clara))
      end
    end

    context "when the county_id is present but no matching county exists" do
      before do
        allow(constituent_double).to receive(:county_id).and_return("999")
        allow(constituent_double).to receive(:county_name).and_return("California : New County")
      end

      it "creates a new county and assigns it" do
        importer = described_class.new(params)
        expect { importer.import }.to change(County, :count).by(1)
      end
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

    context "when the constituent is not an organization" do
      before do
        allow(constituent_double).to receive(:organization?).and_return(false)
        allow(constituent_double).to receive(:netsuite_id).and_return(600)
      end

      it "raises ActiveRecord::RecordInvalid" do
        importer = described_class.new(params)
        expect { importer.import }.to raise_error(ActiveRecord::RecordInvalid, /is not an organization/)
      end
    end
  end
end

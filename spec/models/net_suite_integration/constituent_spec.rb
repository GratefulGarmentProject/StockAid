require "rails_helper"

describe NetSuiteIntegration::Constituent, type: :model do
  let(:profile_item) { double(name: "Donor") }
  let(:classification_item) { double(name: "Major Donor") }
  let(:type_value) { double(name: "Individual") }
  let(:county_region) { double(name: "California : Santa Clara County", internal_id: "42") }
  let(:custom_field_list) do
    double(
      custentity_npo_constituent_profile: double(value: [profile_item]),
      custentity_npo_txn_classification: double(value: [classification_item]),
      custentity_npo_constituent_type: double(value: type_value),
      custentity_cseg_npo_region: double(value: county_region)
    )
  end
  let(:address_book_address) { double(addr1: "123 Main St", city: "San Jose", state: "CA", zip: "95101") }
  let(:address_book_entry) { double(addressbook_address: address_book_address) }
  let(:netsuite_record) do
    double(
      internal_id: "123",
      is_person: true,
      first_name: "Jean-Luc",
      middle_name: "X",
      last_name: "Picard",
      company_name: nil,
      email: "jlpicard@starfleet.com",
      phone: "(510) 555-1234",
      mobile_phone: nil,
      custom_field_list: custom_field_list,
      addressbook_list: double(addressbook: [address_book_entry])
    )
  end

  subject(:constituent) { described_class.new(netsuite_record) }

  describe ".by_id" do
    it "fetches a customer by internal_id and wraps it in a Constituent" do
      allow(NetSuite::Records::Customer).to receive(:get).with(internal_id: 42).and_return(netsuite_record)
      result = NetSuiteIntegration::Constituent.by_id(42)
      expect(result).to be_a(NetSuiteIntegration::Constituent)
    end
  end

  describe ".grateful_garment_subsidiary" do
    it "returns the subsidiary hash" do
      expect(described_class.grateful_garment_subsidiary).to eq(internal_id: "1")
    end
  end

  describe ".netsuite_type" do
    it "returns a hash for a known type" do
      expect(described_class.netsuite_type("Individual")).to eq(internal_id: "3")
    end

    it "raises for an unknown type" do
      expect { described_class.netsuite_type("Unknown") }.to raise_error(/Unknown NetSuite type/)
    end
  end

  describe ".netsuite_profile" do
    it "returns a CustomRecordRef for Agency" do
      result = described_class.netsuite_profile("Agency")
      expect(result).to be_a(NetSuite::Records::CustomRecordRef)
      expect(result.internal_id).to eq("8")
    end

    it "returns a CustomRecordRef for Donor" do
      result = described_class.netsuite_profile("Donor")
      expect(result.internal_id).to eq("9")
    end

    it "raises for an unknown profile" do
      expect { described_class.netsuite_profile("Unknown") }.to raise_error(/Unknown NetSuite profile/)
    end
  end

  describe ".netsuite_classification" do
    it "returns a CustomRecordRef for Agency" do
      result = described_class.netsuite_classification("Agency")
      expect(result).to be_a(NetSuite::Records::CustomRecordRef)
      expect(result.internal_id).to eq("8")
    end

    it "returns a CustomRecordRef for Donor" do
      result = described_class.netsuite_classification("Donor")
      expect(result.internal_id).to eq("1")
    end

    it "raises for an unknown classification" do
      expect { described_class.netsuite_classification("Unknown") }.to raise_error(/Unknown NetSuite classification/)
    end
  end

  describe ".netsuite_address" do
    context "with all parts present" do
      let(:address) do
        double(
          all_parts_present?: true,
          street_address: "123 Main St",
          city: "San Jose",
          state: "CA",
          zip: "95101"
        )
      end

      it "returns a CustomerAddressbook" do
        result = described_class.netsuite_address(address)
        expect(result).to be_a(NetSuite::Records::CustomerAddressbook)
      end
    end

    context "with an address that doesn't have all parts" do
      let(:address) do
        double(
          all_parts_present?: false,
          address: "Unknown Address Format"
        )
      end

      it "returns nil when address doesn't match the expected pattern" do
        expect(described_class.netsuite_address(address)).to be_nil
      end
    end

    context "with no address" do
      it "returns nil" do
        expect(described_class.netsuite_address(nil)).to be_nil
      end
    end
  end

  describe "#donor?" do
    it "returns true when constituent profile includes Donor" do
      expect(constituent.donor?).to be true
    end

    it "returns false when profile is not Donor" do
      allow(profile_item).to receive(:name).and_return("Agency")
      allow(classification_item).to receive(:name).and_return("Other")
      expect(constituent.donor?).to be false
    end
  end

  describe "#organization?" do
    it "returns false when profile is not Agency" do
      expect(constituent.organization?).to be false
    end

    it "returns true when profile is Agency" do
      allow(profile_item).to receive(:name).and_return("Agency")
      expect(constituent.organization?).to be true
    end
  end

  describe "#netsuite_id" do
    it "returns the internal_id as integer" do
      expect(constituent.netsuite_id).to eq(123)
    end
  end

  describe "#name" do
    it "returns full name for a person" do
      expect(constituent.name).to eq("Jean-Luc X Picard")
    end

    it "returns company_name for a non-person" do
      allow(netsuite_record).to receive(:is_person).and_return(false)
      allow(netsuite_record).to receive(:company_name).and_return("Starfleet Command")
      expect(constituent.name).to eq("Starfleet Command")
    end
  end

  describe "#type" do
    it "returns the type name from the custom field" do
      expect(constituent.type).to eq("Individual")
    end
  end

  describe "#email" do
    it "returns the email" do
      expect(constituent.email).to eq("jlpicard@starfleet.com")
    end
  end

  describe "#phone" do
    it "returns the phone" do
      expect(constituent.phone).to eq("(510) 555-1234")
    end

    it "falls back to mobile_phone when phone is nil" do
      allow(netsuite_record).to receive(:phone).and_return(nil)
      allow(netsuite_record).to receive(:mobile_phone).and_return("(408) 555-9999")
      expect(constituent.phone).to eq("(408) 555-9999")
    end
  end

  describe "#address" do
    it "returns address hash from first addressbook entry" do
      result = constituent.address
      expect(result).to include(street_address: "123 Main St", city: "San Jose", state: "CA", zip: "95101")
    end

    it "returns nil when no addressbook entries" do
      allow(netsuite_record).to receive(:addressbook_list).and_return(double(addressbook: []))
      expect(constituent.address).to be_nil
    end
  end

  describe "#county_name" do
    it "returns the county name from the custom field" do
      expect(constituent.county_name).to eq("California : Santa Clara County")
    end
  end

  describe "#county_id" do
    it "returns the county external id" do
      expect(constituent.county_id).to eq("42")
    end
  end
end

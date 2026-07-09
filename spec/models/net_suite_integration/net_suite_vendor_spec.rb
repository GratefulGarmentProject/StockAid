require "rails_helper"

describe NetSuiteIntegration::NetSuiteVendor, type: :model do
  let(:address_book_address) { double(addr1: "456 Vendor Lane", city: "Oakland", state: "CA", zip: "94601") }
  let(:address_book_entry) { double(addressbook_address: address_book_address) }
  let(:company_record) do
    double(
      internal_id: "99",
      is_person: false,
      first_name: nil,
      middle_name: nil,
      last_name: nil,
      company_name: "Guinan's Adventures",
      email: "guinan@enterprise.com",
      phone: "(510) 555-7777",
      mobile_phone: nil,
      addressbook_list: double(addressbook: [address_book_entry])
    )
  end
  let(:person_record) do
    double(
      internal_id: "100",
      is_person: true,
      first_name: "Guinan",
      middle_name: nil,
      last_name: nil,
      company_name: nil,
      email: "guinan@personal.com",
      phone: nil,
      mobile_phone: "(510) 555-8888",
      addressbook_list: double(addressbook: [])
    )
  end

  describe ".by_id" do
    it "fetches a vendor by id and wraps it in a NetSuiteVendor" do
      allow(NetSuite::Records::Vendor).to receive(:get).with(internal_id: 99).and_return(company_record)
      result = NetSuiteIntegration::NetSuiteVendor.by_id(99)
      expect(result).to be_a(NetSuiteIntegration::NetSuiteVendor)
    end
  end

  describe "#netsuite_id" do
    it "returns the internal_id as integer" do
      vendor = described_class.new(company_record)
      expect(vendor.netsuite_id).to eq(99)
    end
  end

  describe "#name" do
    it "returns company_name for a company" do
      vendor = described_class.new(company_record)
      expect(vendor.name).to eq("Guinan's Adventures")
    end

    it "returns full name for a person" do
      vendor = described_class.new(person_record)
      expect(vendor.name).to eq("Guinan")
    end
  end

  describe "#type" do
    it "returns Company for a company record" do
      vendor = described_class.new(company_record)
      expect(vendor.type).to eq("Company")
    end

    it "returns Individual for a person record" do
      vendor = described_class.new(person_record)
      expect(vendor.type).to eq("Individual")
    end
  end

  describe "#email" do
    it "returns the email" do
      vendor = described_class.new(company_record)
      expect(vendor.email).to eq("guinan@enterprise.com")
    end
  end

  describe "#phone" do
    it "returns the phone" do
      vendor = described_class.new(company_record)
      expect(vendor.phone).to eq("(510) 555-7777")
    end

    it "falls back to mobile_phone when phone is nil" do
      vendor = described_class.new(person_record)
      expect(vendor.phone).to eq("(510) 555-8888")
    end
  end

  describe "#address" do
    it "returns address hash from first addressbook entry" do
      vendor = described_class.new(company_record)
      result = vendor.address
      expect(result).to include(street_address: "456 Vendor Lane", city: "Oakland", state: "CA", zip: "94601")
    end

    it "returns nil when no addressbook entries" do
      vendor = described_class.new(person_record)
      expect(vendor.address).to be_nil
    end
  end
end

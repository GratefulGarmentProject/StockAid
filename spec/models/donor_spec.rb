require "rails_helper"

describe Donor, type: :model do
  context ".primary_address" do
    it "returns the first address" do
      donor_1 = donors(:starfleet_command)

      expect(donor_1.primary_address).to eq(nil)

      donor_1.update!(addresses_attributes: { id: nil, address: "foo" })

      expect(donor_1.primary_address).to eq("foo")

      donor_1.update!(addresses_attributes: { id: nil, address: "bar" })

      expect(donor_1.primary_address).to eq("foo")
      expect(donor_1.addresses.second.address).to eq("bar")
    end
  end

  describe "importing from NetSuite" do
    it "can create a donor from NetSuite" do
      constituent = double("NetSuiteIntegration::Constituent")
      allow(NetSuiteIntegration::Constituent).to receive(:by_id).with(42).and_return constituent

      expect(constituent).to receive(:donor?).and_return(true)
      expect(constituent).to receive(:name).and_return("Foo Donor")
      expect(constituent).to receive(:netsuite_id).and_return(42)
      expect(constituent).to receive(:type).and_return("Individual")
      expect(constituent).to receive(:email).and_return("foo@donor.com")
      expect(constituent).to receive(:phone).and_return("408-444-1232")
      expect(constituent).to receive(:address).and_return(
        street_address: "123 Fake Str",
        city: "San Jose",
        state: "CA",
        zip: "95123"
      )

      donor = NetSuiteIntegration::DonorImporter.new(ActionController::Parameters.new(external_id: "42")).import
      expect(donor.name).to eq("Foo Donor")
      expect(donor.external_id).to eq(42)
      expect(donor.external_type).to eq("Individual")
      expect(donor.email).to eq("foo@donor.com")
      expect(donor.primary_number).to eq("408-444-1232")
      expect(donor.addresses.first.street_address).to eq("123 Fake Str")
      expect(donor.addresses.first.city).to eq("San Jose")
      expect(donor.addresses.first.state).to eq("CA")
      expect(donor.addresses.first.zip).to eq("95123")
    end
  end

  describe "create and export to NetSuite" do
    it "won't export without the save_and_export_donor param" do
      params = ActionController::Parameters.new(
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          primary_number: "408-444-1232",
          secondary_number: "",
          addresses_attributes: {
            "0" => {
              street_address: "123 Fake Str",
              city: "San Jose",
              state: "CA",
              zip: "95123"
            }
          }
        }
      )

      expect_any_instance_of(NetSuiteIntegration::DonorExporter).to_not receive(:export)
      donor = NetSuiteIntegration::DonorExporter.create_and_export(params)
      expect(donor.name).to eq("Foo Donor")
      expect(donor.email).to eq("foo@donor.com")
      expect(donor.external_type).to eq("Individual")
      expect(donor.primary_number).to eq("408-444-1232")
      expect(donor.secondary_number).to eq("")
      expect(donor.primary_address).to eq("123 Fake Str, San Jose, CA 95123")
    end

    it "exports the donor with the save_and_export_donor = true param" do
      params = ActionController::Parameters.new(
        save_and_export_donor: "true",
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          primary_number: "408-444-1232",
          secondary_number: "",
          addresses_attributes: {
            "0" => {
              street_address: "123 Fake Str",
              city: "San Jose",
              state: "CA",
              zip: "95123"
            }
          }
        }
      )

      received_donor = nil
      exporter_stub = double("NetSuiteIntegration::DonorExporter")

      expect(NetSuiteIntegration::DonorExporter).to receive(:new) do |donor|
        received_donor = donor
        exporter_stub
      end

      expect(exporter_stub).to receive(:export)
      donor = NetSuiteIntegration::DonorExporter.create_and_export(params)

      expect(received_donor).to eq(donor)
      expect(donor.name).to eq("Foo Donor")
      expect(donor.email).to eq("foo@donor.com")
      expect(donor.external_type).to eq("Individual")
      expect(donor.primary_number).to eq("408-444-1232")
      expect(donor.secondary_number).to eq("")
      expect(donor.primary_address).to eq("123 Fake Str, San Jose, CA 95123")
    end

    it "receives a donor with an address that can be split apart when being exported" do
      params = ActionController::Parameters.new(
        save_and_export_donor: "true",
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          primary_number: "408-444-1232",
          secondary_number: "",
          addresses_attributes: {
            "0" => {
              street_address: "123 Fake Str",
              city: "San Jose",
              state: "CA",
              zip: "95123"
            }
          }
        }
      )

      exporter_stub = double("NetSuiteIntegration::DonorExporter")
      expect(exporter_stub).to receive(:export)

      expect(NetSuiteIntegration::DonorExporter).to receive(:new) do |donor|
        expect(donor).to be
        expect(donor.addresses.first).to be
        expect(donor.addresses.first.address).to eq("123 Fake Str, San Jose, CA 95123")
        expect(donor.addresses.first.street_address).to eq("123 Fake Str")
        expect(donor.addresses.first.city).to eq("San Jose")
        expect(donor.addresses.first.state).to eq("CA")
        expect(donor.addresses.first.zip).to eq("95123")
        exporter_stub
      end

      NetSuiteIntegration::DonorExporter.create_and_export(params)
    end

    it "attempts to export the donor correctly" do
      params = ActionController::Parameters.new(
        save_and_export_donor: "true",
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          primary_number: "408-444-1232",
          secondary_number: "",
          addresses_attributes: {
            "0" => {
              street_address: "123 Fake Str",
              city: "San Jose",
              state: "CA",
              zip: "95123"
            }
          }
        }
      )

      constituent = double("NetSuite::Records::Customer")
      custom_fields = double("NetSuite::Records::CustomFieldList")
      addressbook = double("NetSuite::Records::CustomerAddressbookList")
      addresses = []
      allow(constituent).to receive(:custom_field_list).and_return(custom_fields)
      allow(constituent).to receive(:addressbook_list).and_return(addressbook)
      allow(addressbook).to receive(:addressbook).and_return(addresses)
      expect(NetSuiteIntegration::Constituent).to receive(:netsuite_profile).with("Donor").and_return(:donor_profile)
      expect(NetSuiteIntegration::Constituent).to receive(:netsuite_classification).with("Donor").and_return(:donor_classification)

      expect(constituent).to receive(:is_person=).with(true)
      expect(constituent).to receive(:first_name=).with("Foo")
      expect(constituent).to receive(:last_name=).with("Donor")
      expect(constituent).to receive(:subsidiary=).with(internal_id: "1")
      expect(constituent).to receive(:email=).with("foo@donor.com")
      expect(constituent).to receive(:phone=).with("408-444-1232")
      expect(custom_fields).to receive(:custentity_npo_constituent_type=).with(internal_id: NetSuiteIntegration::Constituent::NETSUITE_TYPES["Individual"])
      expect(custom_fields).to receive(:custentity_npo_constituent_profile=).with([:donor_profile])
      expect(custom_fields).to receive(:custentity_npo_txn_classification=).with([:donor_classification])
      expect(constituent).to receive(:add).and_return(true)
      expect(constituent).to receive(:internal_id).and_return("42")
      expect(NetSuite::Records::Customer).to receive(:new).and_return(constituent)

      donor = NetSuiteIntegration::DonorExporter.create_and_export(params)

      expect(donor.external_id).to eq(42)
      expect(addresses.size).to eq(1)
      expect(addresses.first.addressbook_address.addr1).to eq("123 Fake Str")
      expect(addresses.first.addressbook_address.city).to eq("San Jose")
      expect(addresses.first.addressbook_address.state).to eq("CA")
      expect(addresses.first.addressbook_address.zip).to eq("95123")
    end
  end
end

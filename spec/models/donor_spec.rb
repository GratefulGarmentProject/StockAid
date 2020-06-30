require "rails_helper"

describe Donor, type: :model do
  describe ".create_and_export_to_netsuite!" do
    it "won't export without the save_and_export_donor param" do
      params = ActionController::Parameters.new(
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          phone_number: "408-444-1232",
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

      expect(NetSuiteConstituent).to_not receive(:export_donor)
      donor = Donor.create_and_export_to_netsuite!(params)
      expect(donor.name).to eq("Foo Donor")
      expect(donor.email).to eq("foo@donor.com")
      expect(donor.external_type).to eq("Individual")
      expect(donor.phone_number).to eq("408-444-1232")
      expect(donor.primary_address).to eq("123 Fake Str, San Jose, CA 95123")
    end

    it "exports the donor with the save_and_export_donor = true param" do
      params = ActionController::Parameters.new(
        save_and_export_donor: "true",
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          phone_number: "408-444-1232",
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

      allow(NetSuiteConstituent).to receive(:export_donor)
      donor = Donor.create_and_export_to_netsuite!(params)
      expect(NetSuiteConstituent).to have_received(:export_donor).with(donor)
    end

    it "receives a donor with an address that can be split apart when being exported" do
      params = ActionController::Parameters.new(
        save_and_export_donor: "true",
        donor: {
          name: "Foo Donor",
          email: "foo@donor.com",
          external_type: "Individual",
          phone_number: "408-444-1232",
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

      expect(NetSuiteConstituent).to receive(:export_donor) do |donor|
        expect(donor).to be
        expect(donor.addresses.first).to be
        expect(donor.addresses.first.address).to eq("123 Fake Str, San Jose, CA 95123")
        expect(donor.addresses.first.street_address).to eq("123 Fake Str")
        expect(donor.addresses.first.city).to eq("San Jose")
        expect(donor.addresses.first.state).to eq("CA")
        expect(donor.addresses.first.zip).to eq("95123")
      end

      Donor.create_and_export_to_netsuite!(params)
    end
  end
end

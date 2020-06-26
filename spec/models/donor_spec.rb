require "rails_helper"

describe Donor do
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
end

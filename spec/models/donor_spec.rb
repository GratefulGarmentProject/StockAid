require "rails_helper"

describe Donor do
  context ".primary_address" do
    it "returns the first address" do
      donor1 = donors(:starfleet_command)

      expect(donor1.primary_address).to eq(nil)

      donor1.update!(addresses_attributes: { id: nil, address: "foo" })

      expect(donor1.primary_address).to eq("foo")

      donor1.update!(addresses_attributes: { id: nil, address: "bar" })

      expect(donor1.primary_address).to eq("foo")
      expect(donor1.addresses.second.address).to eq("bar")
    end
  end
end

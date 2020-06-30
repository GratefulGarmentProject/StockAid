require "rails_helper"

describe Address, type: :model do
  it "can be created with standard parts of an address" do
    address = Address.create! do |a|
      a.street_address = "123 Fake Str"
      a.city = "San Jose"
      a.state = "CA"
      a.zip = "95123"
    end

    expect(address.address).to eq("123 Fake Str, San Jose, CA 95123")
    expect(address.reload.address).to eq("123 Fake Str, San Jose, CA 95123")
  end

  it "can be created with standard parts of an address via a hash" do
    address = Address.create!(street_address: "123 Fake Str", city: "San Jose", state: "CA", zip: "95123")
    expect(address.address).to eq("123 Fake Str, San Jose, CA 95123")
    expect(address.reload.address).to eq("123 Fake Str, San Jose, CA 95123")
  end

  it "can be created with a single address line" do
    address = Address.create! do |a|
      a.address = "123 Fake Str, San Jose, CA 95123"
    end

    expect(address.reload.address).to eq("123 Fake Str, San Jose, CA 95123")
  end
end

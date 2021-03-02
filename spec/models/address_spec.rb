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

  it "can be updated with a single address line if it was originally created with one" do
    address = Address.create! do |a|
      a.address = "123 Fake Str, San Jose, CA 95123"
    end

    address.address = "333 Other Ave, San Jose, CA 95122"
    address.save!
    expect(address.reload.address).to eq("333 Other Ave, San Jose, CA 95122")
  end

  it "can be updated with standard parts of an address" do
    address = Address.create! do |a|
      a.street_address = "123 Fake Str"
      a.city = "San Jose"
      a.state = "CA"
      a.zip = "95123"
    end

    address.street_address = "333 Other Ave"
    address.zip = "95122"
    address.save!
    expect(address.reload.address).to eq("333 Other Ave, San Jose, CA 95122")
  end

  it "prevents addresses created from parts to be updated via just the address line" do
    address = Address.create! do |a|
      a.street_address = "123 Fake Str"
      a.city = "San Jose"
      a.state = "CA"
      a.zip = "95123"
    end

    address.address = "333 Other Ave, San Jose, CA 95122"
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Address cannot be changed directly, please change the parts instead!")
    expect(address.reload.address).to eq("123 Fake Str, San Jose, CA 95123")
  end

  it "prevents creating partial address" do
    expect { Address.create!(street_address: "123 Fake Str", state: "CA") }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Address parts must all be provided!")
    expect { Address.create!(city: "San Jose", zip: "95123") }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Address parts must all be provided!")
  end

  it "prevents saving as a partial address" do
    address = Address.create! do |a|
      a.street_address = "123 Fake Str"
      a.city = "San Jose"
      a.state = "CA"
      a.zip = "95123"
    end

    address.city = ""
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Address parts must all be provided!")
  end
end

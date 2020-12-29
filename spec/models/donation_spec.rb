require "rails_helper"

describe Donation do
  describe ".formatted_donation_date" do
    it "returns the correctly formated date" do
      donation = donations(:starfleet_commands_donation)

      expected_result = "#{Time.zone.now.month}/#{Time.zone.now.day}/#{Time.zone.now.year}"

      expect(donation.formatted_donation_date).to eq(expected_result)
    end
  end

  describe ".value" do
    it "has no value with no details" do
      donation = donations(:starfleet_commands_donation)

      expect(donation.value).to eq(0.0)
    end

    it "has no value with details with no value" do
      donation = donations(:starfleet_commands_donation)

      donation.donation_details.build(quantity: 0, value: 5.0)
      donation.donation_details.build(quantity: 5, value: 0.0)

      expect(donation.value).to eq(0.0)
    end

    it "value equal to all details full value" do
      donation = donations(:starfleet_commands_donation)

      donation.donation_details.build(quantity: 1, value: 5.0)
      donation.donation_details.build(quantity: 2, value: 2.0)
      donation.donation_details.build(quantity: 3, value: 3.0)

      expect(donation.value).to eq(18.0)
    end
  end

  describe ".item_count" do
    it "has no item_count with no details" do
      donation = donations(:starfleet_commands_donation)

      expect(donation.item_count).to eq(0)
    end

    it "has no item_count with details with no quantity" do
      donation = donations(:starfleet_commands_donation)

      donation.donation_details.build(quantity: 0, value: 5.0)
      donation.donation_details.build(quantity: 5, value: 0.0)

      expect(donation.item_count).to eq(5)
    end

    it "item_count equal to sum of details quantities" do
      donation = donations(:starfleet_commands_donation)

      donation.donation_details.build(quantity: 1, value: 5.0)
      donation.donation_details.build(quantity: 2, value: 2.0)
      donation.donation_details.build(quantity: 3, value: 3.0)

      expect(donation.item_count).to eq(6)
    end
  end

  describe ".create_values_for_programs" do
    let(:donation) { donations(:trois_donation) }
    let(:resource_closets) { programs(:resource_closets) }
    let(:pack_it_forward) { programs(:pack_it_forward) }

    it "creates program details with proper split of values" do
      expect(donation.donation_program_details.size).to eq(0)
      donation.create_values_for_programs
      donation.reload
      donation_values = donation.value_by_program
      # 20 from small flip flops and 20 from large pants
      expect(donation_values[resource_closets]).to eq(40.00)
      # 20 from large pants
      expect(donation_values[pack_it_forward]).to eq(20.00)
    end
  end
end

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

  describe "closing donations" do
    let(:donation) { donations(:trois_donation) }
    let(:donation_with_unsynced_donor) { donations(:picards_donation) }
    let(:resource_closets) { programs(:resource_closets) }
    let(:pack_it_forward) { programs(:pack_it_forward) }

    it "creates the program split values" do
      expect(donation.donation_program_details.size).to eq(0)
      expect(donation.closed_at).to be_nil
      donation.close
      donation.reload
      expect(donation.closed_at).to_not be_nil
      donation_values = donation.value_by_program
      # 20 from small flip flops and 20 from large pants
      expect(donation_values[resource_closets]).to eq(40.00)
      # 20 from large pants
      expect(donation_values[pack_it_forward]).to eq(20.00)
    end

    it "cannot have new items added" do
      donation.close
      donation.donation_details.build(item: items(:large_flip_flops), quantity: 1, value: 10.0)
      expect { donation.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "cannot have new items added by saving new details" do
      donation.close

      expect do
        donation.donation_details.create!(item: items(:large_flip_flops), quantity: 1, value: 10.0)
      end.to raise_error(ActiveRecord::RecordInvalid)

      expect do
        DonationDetail.create!(donation: donation, item: items(:large_flip_flops), quantity: 1, value: 10.0)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "cannot be closed if the donor is not yet synced to netsuite" do
      expect(donation_with_unsynced_donor.donor).to_not be_synced
      expect(donation_with_unsynced_donor).to_not be_closed

      expect do
        donation_with_unsynced_donor.close
      end.to raise_error(/Donation cannot be closed until donor is synced/)

      donation_with_unsynced_donor.reload
      expect(donation_with_unsynced_donor).to_not be_closed
    end

    it "starts a sync to netsuite" do
      expect(donation.donor).to be_synced
      expect(donation.external_id).to be_nil

      expect do
        donation.close
      end.to have_enqueued_job(ExportDonationJob).with(donation.id)

      donation.reload
      expect(donation.external_id).to eq(NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID)
    end

    it "can have the external id changed after being closed" do
      donation.close
      donation.external_id = 123

      expect do
        donation.save!
      end.to_not raise_error
    end

    it "can have an empty save after being closed" do
      donation.close

      expect do
        donation.save!
      end.to_not raise_error
    end
  end

  describe "#soft_delete_closed" do
    context "with a non-closed donation" do
      let(:donation) { donations(:open_donation) }

      it "blocks the delete" do
        expect { donation.soft_delete_closed }.to raise_error(/is not closed/)
      end
    end

    context "with a closed donation with no notes" do
      let(:donation) { donations(:fully_synced_donation) }

      it "adds a note to the donation" do
        donation.soft_delete_closed
        donation.reload
        expect(donation.notes).to match(/This donation was deleted after being closed/)
      end
    end

    context "with a closed donation with notes" do
      let(:donation) { donations(:fully_synced_donation) }
      let(:affected_item_1) { items(:small_flip_flops) }
      let(:affected_item_2) { items(:large_pants) }

      it "adds a note to the donation" do
        donation.soft_delete_closed
        donation.reload
        expect(donation.notes).to match(/This has already been synced to NetSuite/)
        expect(donation.notes).to match(/This donation was deleted after being closed/)
      end

      it "marks all the donated items as 0 and sets all value to 0" do
        donation.soft_delete_closed
        donation.reload
        expect(donation.value).to be_zero
        expect(donation.donation_details).to be_present
        expect(donation.donation_program_details).to be_present

        donation.donation_details.each do |detail|
          expect(detail.quantity).to be_zero
        end

        donation.donation_program_details.each do |detail|
          expect(detail.value).to be_zero
        end
      end

      it "removes the equivalent stock" do
        quantity_1_before = affected_item_1.current_quantity
        quantity_2_before = affected_item_2.current_quantity
        donation.soft_delete_closed
        affected_item_1.reload
        affected_item_2.reload
        expect(affected_item_1.current_quantity).to eq(quantity_1_before - 2)
        expect(affected_item_2.current_quantity).to eq(quantity_2_before - 4)
      end

      it "adds a history of the removal of stock" do
        versions_1_before = affected_item_1.versions.to_a
        versions_2_before = affected_item_2.versions.to_a
        donation.soft_delete_closed
        affected_item_1.reload
        affected_item_2.reload
        expect(affected_item_1.versions.size).to eq(versions_1_before.size + 1)
        expect(affected_item_2.versions.size).to eq(versions_2_before.size + 1)
        version_item_1 = (affected_item_1.versions - versions_1_before).first
        version_item_2 = (affected_item_2.versions - versions_2_before).first

        expect(version_item_1.edit_reason).to eq("donation_adjustment")
        expect(version_item_1.edit_method).to eq("subtract")
        expect(version_item_1.edit_amount).to eq(2)
        expect(version_item_1.edit_source).to eq("Donation ##{donation.id} deleted after closed")

        expect(version_item_2.edit_reason).to eq("donation_adjustment")
        expect(version_item_2.edit_method).to eq("subtract")
        expect(version_item_2.edit_amount).to eq(4)
        expect(version_item_2.edit_source).to eq("Donation ##{donation.id} deleted after closed")
      end
    end

    context "with a closed donation with not enough stock to delete" do
      let(:donation) { donations(:fully_synced_donation) }
      let(:affected_item_1) { items(:small_flip_flops) }
      let(:affected_item_2) { items(:large_pants) }

      it "removes the equivalent stock down to negative values and adds a history of the removal of stock" do
        affected_item_1.current_quantity = 1
        affected_item_2.current_quantity = 2
        affected_item_1.save!
        affected_item_2.save!

        versions_1_before = affected_item_1.versions.to_a
        versions_2_before = affected_item_2.versions.to_a

        donation.soft_delete_closed

        affected_item_1.reload
        affected_item_2.reload

        expect(affected_item_1.current_quantity).to eq(-1)
        expect(affected_item_2.current_quantity).to eq(-2)

        expect(affected_item_1.versions.size).to eq(versions_1_before.size + 1)
        expect(affected_item_2.versions.size).to eq(versions_2_before.size + 1)
        version_item_1 = (affected_item_1.versions - versions_1_before).first
        version_item_2 = (affected_item_2.versions - versions_2_before).first

        expect(version_item_1.edit_reason).to eq("donation_adjustment")
        expect(version_item_1.edit_method).to eq("subtract")
        expect(version_item_1.edit_amount).to eq(2)
        expect(version_item_1.edit_source).to eq("Donation ##{donation.id} deleted after closed")

        expect(version_item_2.edit_reason).to eq("donation_adjustment")
        expect(version_item_2.edit_method).to eq("subtract")
        expect(version_item_2.edit_amount).to eq(4)
        expect(version_item_2.edit_source).to eq("Donation ##{donation.id} deleted after closed")
      end
    end

    context "with an already deleted closed donation" do
      let(:donation) { donations(:fully_synced_donation) }

      it "blocks the delete" do
        donation.soft_delete_closed

        expect { donation.soft_delete_closed }.to raise_error(/already deleted/)
      end
    end
  end
end

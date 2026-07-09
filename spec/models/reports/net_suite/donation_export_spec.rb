require "rails_helper"

describe Reports::NetSuite::DonationExport, type: :model do
  let(:session) { {} }

  subject(:export) { described_class.new(session) }

  describe "#records_present?" do
    it "returns true when there are active donations" do
      expect(export.records_present?).to be true
    end
  end

  describe "#each" do
    it "yields rows for each donation" do
      rows = []
      export.each { |row| rows << row } # rubocop:disable Style/MapIntoArray
      expect(rows).not_to be_empty
      expect(rows.first).to be_a(Reports::NetSuite::DonationExport::Row)
    end
  end

  describe "Row" do
    let(:donation) { donations(:picards_donation) }

    subject(:row) { Reports::NetSuite::DonationExport::Row.new(donation) }

    describe "#donation_id" do
      it "returns the donation id" do
        expect(row.donation_id).to eq(donation.id)
      end
    end

    describe "#donation_date" do
      it "returns formatted date" do
        expect(row.donation_date).to match(%r{\d{2}/\d{2}/\d{4}})
      end
    end

    describe "#donor_name" do
      it "returns the donor's name" do
        expect(row.donor_name).to eq(donation.donor.name)
      end
    end

    describe "#memo" do
      it "includes the donation user's name" do
        expect(row.memo).to include(donation.user.name)
      end
    end

    describe "#item_name" do
      it "returns 'in-kind donation'" do
        expect(row.item_name).to eq("in-kind donation")
      end
    end

    describe "#value" do
      it "returns the donation value as a string" do
        expect(row.value).to be_a(String)
      end
    end
  end
end

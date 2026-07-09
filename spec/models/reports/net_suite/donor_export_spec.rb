require "rails_helper"

describe Reports::NetSuite::DonorExport, type: :model do
  let(:session) { {} }

  subject(:export) { described_class.new(session) }

  describe "#records_present?" do
    it "returns true when there are active donors" do
      expect(export.records_present?).to be true
    end
  end

  describe "#each" do
    it "yields rows for each donor" do
      rows = []
      export.each { |row| rows << row }
      expect(rows).not_to be_empty
      expect(rows.first).to be_a(Reports::NetSuite::DonorExport::Row)
    end
  end

  describe "Row" do
    let(:donor) { donors(:picard) }

    subject(:row) { Reports::NetSuite::DonorExport::Row.new(donor) }

    describe "#id" do
      it "returns prefixed donor id" do
        expect(row.id).to eq("Donor-#{donor.id}")
      end
    end

    describe "#name" do
      it "returns the donor name" do
        expect(row.name).to eq(donor.name)
      end
    end

    describe "#email" do
      it "returns the donor email" do
        expect(row.email).to eq(donor.email)
      end
    end

    describe "#created_date" do
      it "returns formatted creation date" do
        expect(row.created_date).to match(/\d{2}\/\d{2}\/\d{4}/)
      end
    end

    describe "#external_id" do
      it "returns the donor external_id" do
        expect(row.external_id).to eq(donor.external_id)
      end
    end

    describe "#external_type" do
      it "returns the donor external_type" do
        expect(row.external_type).to eq(donor.external_type)
      end
    end
  end
end

require "rails_helper"

describe Reports::NetSuite::OrganizationExport, type: :model do
  let(:session) { {} }

  subject(:export) { described_class.new(session) }

  describe "#records_present?" do
    it "returns true when there are organizations" do
      expect(export.records_present?).to be true
    end
  end

  describe "#each" do
    it "yields rows for each organization" do
      rows = []
      export.each { |row| rows << row } # rubocop:disable Style/MapIntoArray
      expect(rows).not_to be_empty
      expect(rows.first).to be_a(Reports::NetSuite::OrganizationExport::Row)
    end
  end

  describe "Row" do
    let(:organization) { organizations(:acme) }

    subject(:row) { Reports::NetSuite::OrganizationExport::Row.new(organization) }

    describe "#id" do
      it "returns prefixed organization id" do
        expect(row.id).to eq("Organization-#{organization.id}")
      end
    end

    describe "#name" do
      it "returns the organization name" do
        expect(row.name).to eq(organization.name)
      end
    end

    describe "#created_date" do
      it "returns formatted creation date" do
        expect(row.created_date).to match(%r{\d{2}/\d{2}/\d{4}})
      end
    end

    describe "#external_id" do
      it "returns the organization external_id" do
        expect(row.external_id).to eq(organization.external_id)
      end
    end

    it "exposes all address fields without error" do
      expect { row.address1_attention }.not_to raise_error
      expect { row.address1_addr1 }.not_to raise_error
      expect { row.address1_addr2 }.not_to raise_error
      expect { row.address1_city }.not_to raise_error
      expect { row.address1_state }.not_to raise_error
      expect { row.address1_zip }.not_to raise_error
      expect { row.address2_attention }.not_to raise_error
      expect { row.address2_addr1 }.not_to raise_error
      expect { row.address2_addr2 }.not_to raise_error
      expect { row.address2_city }.not_to raise_error
      expect { row.address2_state }.not_to raise_error
      expect { row.address2_zip }.not_to raise_error
      expect { row.address3_attention }.not_to raise_error
      expect { row.address3_addr1 }.not_to raise_error
      expect { row.address3_addr2 }.not_to raise_error
      expect { row.address3_city }.not_to raise_error
      expect { row.address3_state }.not_to raise_error
      expect { row.address3_zip }.not_to raise_error
    end
  end
end

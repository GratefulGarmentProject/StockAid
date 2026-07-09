require "rails_helper"

describe Reports::NetSuite::OrderExport, type: :model do
  let(:session) { {} }

  subject(:export) { described_class.new(session) }

  describe "#records_present?" do
    it "returns true when there are closed orders" do
      expect(export.records_present?).to be true
    end
  end

  describe "#each" do
    it "yields rows for each closed order" do
      rows = []
      export.each { |row| rows << row }
      expect(rows).not_to be_empty
      expect(rows.first).to be_a(Reports::NetSuite::OrderExport::Row)
    end
  end

  describe "Row" do
    let(:order) { orders(:closed_order) }

    subject(:row) { Reports::NetSuite::OrderExport::Row.new(order) }

    describe "#order_id" do
      it "returns the order id" do
        expect(row.order_id).to eq(order.id)
      end
    end

    describe "#order_date" do
      it "returns a formatted date" do
        expect(row.order_date).to match(/\d{2}\/\d{2}\/\d{4}/)
      end
    end

    describe "#organization_name" do
      it "returns the organization name" do
        expect(row.organization_name).to eq(order.organization_unscoped.name)
      end
    end

    describe "#memo" do
      it "includes the order user's name" do
        expect(row.memo).to include(order.user.name)
      end
    end

    describe "#value" do
      it "returns order value as string" do
        expect(row.value).to be_a(String)
      end
    end
  end
end

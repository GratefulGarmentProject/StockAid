require "rails_helper"

describe Reports::NetSuite::BaseExport, type: :model do
  let(:user) { users(:root) }
  let(:session) { {} }

  describe "#build" do
    it "builds a DonationExport for 'donations' report type" do
      exporter = described_class.new(user, "donations", session)
      result = exporter.build
      expect(result).to be_a(Reports::NetSuite::DonationExport)
    end

    it "builds a DonorExport for 'donors' report type" do
      exporter = described_class.new(user, "donors", session)
      result = exporter.build
      expect(result).to be_a(Reports::NetSuite::DonorExport)
    end

    it "builds an OrderExport for 'orders' report type" do
      exporter = described_class.new(user, "orders", session)
      result = exporter.build
      expect(result).to be_a(Reports::NetSuite::OrderExport)
    end

    it "returns nil for unknown report types" do
      exporter = described_class.new(user, "unknown", session)
      expect(exporter.build).to be_nil
    end

    it "builds an OrganizationExport for 'organizatios' report type (legacy typo)" do
      exporter = described_class.new(user, "organizatios", session)
      result = exporter.build
      expect(result).to be_a(Reports::NetSuite::OrganizationExport)
    end

    context "when user cannot view donations" do
      let(:user) { users(:acme_normal) }

      it "returns nil for donations report" do
        exporter = described_class.new(user, "donations", session)
        expect(exporter.build).to be_nil
      end
    end
  end
end

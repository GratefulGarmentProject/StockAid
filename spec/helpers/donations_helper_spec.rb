require "rails_helper"

RSpec.describe DonationsHelper, type: :helper do
  describe "#sync_donation_button" do
    let(:donation) { donations(:unsynced_donation) }

    it "renders active link when donor is synced" do
      allow(donation.donor).to receive(:synced?).and_return(true)
      html = helper.sync_donation_button(donation)
      expect(html).to include("Sync to NetSuite")
      expect(html).not_to include("Please sync the donor")
    end

    it "wraps with tooltip when donor is not synced" do
      allow(donation.donor).to receive(:synced?).and_return(false)
      html = helper.sync_donation_button(donation)
      expect(html).to include("Please sync the donor to be able to sync to NetSuite.")
    end
  end

  describe "#close_donation_button" do
    let(:donation) { donations(:unsynced_donation) }

    it "renders close button when donor and revenue stream are synced" do
      allow(donation.donor).to receive(:synced?).and_return(true)
      allow(donation.revenue_stream).to receive(:synced?).and_return(true)
      html = helper.close_donation_button(donation)
      expect(html).to include("Close")
      expect(html).not_to include("disabled-title-wrapper")
    end

    it "wraps with tooltip when donor is not synced" do
      allow(donation.donor).to receive(:synced?).and_return(false)
      allow(donation.revenue_stream).to receive(:synced?).and_return(false)
      html = helper.close_donation_button(donation)
      expect(html).to include("sync the donor to NetSuite")
    end
  end
end

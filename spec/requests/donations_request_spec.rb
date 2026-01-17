require "rails_helper"

RSpec.describe DonationsController, type: :request do
  let!(:user) { users(:root) }

  before do
    sign_in user
  end

  describe "#fix_county" do
    context "when the donation already has a county (even though different from donor)" do
      let(:donation) { donations(:donation_with_donor_with_different_county) }

      before do
        donation.update_column(:closed_at, Time.zone.now)
      end

      it "throws an error" do
        expect(donation.county).not_to eq(donation.donor.county)
        post "/donations/#{donation.id}/fix_county"
        expect(flash[:error]).to be_present

        donation.reload
        expect(donation.county).not_to eq(donation.donor.county)
      end
    end

    context "when the donation doesn't have a county but the donor does" do
      let(:donation) { donations(:donation_with_donor_with_county) }

      before do
        donation.update_column(:closed_at, Time.zone.now)
      end

      it "updates the county" do
        expect(donation.county).to be_blank
        post "/donations/#{donation.id}/fix_county"
        expect(flash[:error]).to be_blank

        donation.reload
        expect(donation.county).to eq(donation.donor.county)
      end
    end

    context "when the donation doesn't have a county but neither does the donor" do
      let(:donation) { donations(:trois_donation) }

      before do
        donation.update_column(:closed_at, Time.zone.now)
      end

      it "throws an error" do
        expect(donation.county).to be_blank
        expect(donation.donor.county).to be_blank
        post "/donations/#{donation.id}/fix_county"
        expect(flash[:error]).to be_present

        donation.reload
        expect(donation.county).to be_blank
      end
    end
  end
end

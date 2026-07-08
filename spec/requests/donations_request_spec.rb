require "rails_helper"

RSpec.describe DonationsController, type: :request do
  let!(:user) { users(:root) }

  before do
    sign_in user
  end

  describe "#index" do
    it "renders ok" do
      get donations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#closed" do
    it "renders ok" do
      get closed_donations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_donations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_donation_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    let(:create_params) do
      {
        selected_donor: donors(:picard).id.to_s,
        donation: {
          date: Date.today.to_s,
          revenue_stream_id: revenue_streams(:active_revenue_stream).id,
          notes: "Test donation",
          donation_details: {
            item_id: [items(:small_flip_flops).id.to_s],
            quantity: ["2"]
          }
        }
      }
    end

    context "with save_and_continue" do
      it "redirects to edit page" do
        post donations_path, params: create_params.merge(button: "save_and_continue")
        expect(response).to have_http_status(:found)
        donation = Donation.order(:id).last
        expect(response).to redirect_to(edit_donation_path(donation))
      end
    end

    context "with default button" do
      it "redirects to donations index" do
        post donations_path, params: create_params
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(donations_path)
      end
    end
  end

  describe "#show" do
    it "renders ok" do
      get donation_path(donations(:picards_donation))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_donation_path(donations(:picards_donation))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    let(:donation) { donations(:picards_donation) }
    let(:update_params) do
      {
        donation: { notes: "Updated note", date: donation.donation_date.to_s }
      }
    end

    context "with save_and_continue" do
      it "redirects to edit page" do
        patch donation_path(donation), params: update_params.merge(button: "save_and_continue")
        expect(response).to redirect_to(edit_donation_path(donation))
      end
    end

    context "with default button" do
      it "redirects to show page" do
        patch donation_path(donation), params: update_params
        expect(response).to redirect_to(donation_path(donation))
      end
    end
  end

  describe "#close" do
    let(:donation) { donations(:open_donation) }

    it "closes the donation and redirects" do
      post close_donation_path(donation)
      expect(response).to redirect_to(donations_path)
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy" do
    it "soft deletes the donation and redirects" do
      donation = donations(:picards_donation)
      delete donation_path(donation)
      expect(response).to redirect_to(donations_path)
    end
  end

  describe "#destroy_closed" do
    let(:donation) { donations(:unsynced_donation) }

    it "deletes a closed donation and redirects" do
      delete destroy_closed_donation_path(donation)
      expect(response).to redirect_to(closed_donations_path)
      expect(flash[:success]).to be_present
    end
  end

  describe "#restore" do
    let(:donation) { donations(:picards_donation) }

    before { donation.soft_delete }

    it "restores the donation and redirects" do
      patch restore_donation_path(donation)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#sync" do
    let(:donation) { donations(:unsynced_donation) }

    before { donation.update_column(:donor_id, donors(:riker).id) }

    it "enqueues the export job and redirects" do
      expect {
        post sync_donation_path(donation)
      }.to have_enqueued_job(ExportDonationJob).with(donation.id)
      expect(response).to redirect_to(donation_path(donation))
    end
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

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get donations_path }.to raise_error(PermissionError)
    end
  end
end

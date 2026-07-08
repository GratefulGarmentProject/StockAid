require "rails_helper"

RSpec.describe DonorsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get donors_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_donor_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_donor_path(donors(:picard))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a donor and redirects" do
      post donors_path, params: {
        donor: {
          name: "Test Donor",
          external_type: "Individual",
          primary_number: "(408) 555-9999",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(donors_path)
      expect(Donor.find_by(name: "Test Donor")).to be_present
    end
  end

  describe "#update" do
    let(:donor) { donors(:picard) }

    it "updates and redirects" do
      patch donor_path(donor), params: {
        donor: {
          name: "Captain Picard Updated",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(donors_path)
      expect(donor.reload.name).to eq("Captain Picard Updated")
    end
  end

  describe "#destroy" do
    context "a donor with donations" do
      it "raises an error (DeletionError) and redirects with flash" do
        delete donor_path(donors(:picard))
        expect(response).to redirect_to(donors_path)
      end
    end

    context "a donor with no donations" do
      let(:donor) { Donor.create!(name: "No Donations Donor", external_type: "Individual", primary_number: "(408) 555-0001") }

      it "deletes the donor and redirects" do
        delete donor_path(donor)
        expect(response).to redirect_to(donors_path)
        expect(flash[:success]).to be_present
      end
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_donors_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#restore" do
    let(:donor) { Donor.create!(name: "Restore Donor", external_type: "Individual", primary_number: "(408) 555-0002") }

    before { donor.soft_delete }

    it "restores and redirects" do
      patch restore_donor_path(donor)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#export" do
    it "returns CSV" do
      get export_donors_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get donors_path }.to raise_error(PermissionError)
    end
  end
end

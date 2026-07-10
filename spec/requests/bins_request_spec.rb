require "rails_helper"

RSpec.describe BinsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get bins_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_bin_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a bin and redirects" do
      post bins_path, params: {
        selected_bin_location: bin_locations(:rack_1_shelf_1).id,
        label_prefix: "SPEC",
        label_suffix: "99"
      }
      expect(response).to redirect_to(bins_path)
      expect(flash[:success]).to be_present
      expect(Bin.not_deleted.find_by(label: "SPEC99")).to be_present
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_bin_path(bins(:empty_bin))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    it "updates the bin and redirects" do
      patch bin_path(bins(:empty_bin)), params: {
        selected_bin_location: bin_locations(:rack_1_shelf_1).id,
        label_prefix: "SPEC",
        label_suffix: "UP"
      }
      expect(response).to redirect_to(bins_path)
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy" do
    it "deletes an empty bin and redirects" do
      delete bin_path(bins(:empty_bin))
      expect(response).to redirect_to(bins_path)
      expect(flash[:success]).to be_present
    end
  end
end

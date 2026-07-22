require "rails_helper"

describe BinLocationsController, type: :controller do
  let(:empty_bin_location) { bin_locations(:empty_bin_location) }
  let(:rack_1_shelf_1) { bin_locations(:rack_1_shelf_1) }
  let(:location_with_only_deleted_bin) { bin_locations(:location_with_only_deleted_bin) }
  let(:empty_bin) { bins(:empty_bin) }
  let(:deleted_bin) { bins(:deleted_bin) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }
  let(:bin_in_deleted_only_location) { bins(:bin_in_deleted_only_location) }
  let(:small_flip_flops) { items(:small_flip_flops) }
  let(:large_flip_flops) { items(:large_flip_flops) }

  describe "GET index" do
    render_views

    it "includes bins with their contents" do
      signed_in_user :root
      get :index
      expect(response.body).to have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] div[data-bin-id='#{empty_bin.id}']")
      expect(response.body).to have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] div[data-bin-id='#{empty_bin.id}'] h4", text: empty_bin.label)
      expect(response.body).to have_selector("div[data-bin-id='#{empty_bin.id}'] em", text: "This bin is empty")
      expect(response.body).to_not have_selector("div[data-bin-id='#{empty_bin.id}'] li")

      expect(response.body).to have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] div[data-bin-id='#{flip_flop_bin.id}']")
      expect(response.body).to have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] div[data-bin-id='#{flip_flop_bin.id}'] h4", text: flip_flop_bin.label)
      expect(response.body).to have_selector("div[data-bin-id='#{flip_flop_bin.id}'] li", text: small_flip_flops.description)
      expect(response.body).to have_selector("div[data-bin-id='#{flip_flop_bin.id}'] li", text: large_flip_flops.description)
    end

    it "doesnt include deleted bins" do
      signed_in_user :root
      get :index
      expect(response.body).to_not have_selector("div[data-bin-id='#{deleted_bin.id}']")
    end

    it "shows the delete button for empty locations" do
      expect(empty_bin_location).to be_deletable
      signed_in_user :root
      get :index
      expect(response.body).to have_selector("div[data-bin-location-id='#{empty_bin_location.id}'] a", text: "Delete")
    end

    it "doesn't show delete button for non-empty locations" do
      signed_in_user :root
      get :index
      expect(response.body).to_not have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] a", text: "Delete")
    end

    it "excludes soft-deleted locations" do
      location_with_only_deleted_bin.soft_delete
      signed_in_user :root
      get :index
      expect(response.body).to_not have_selector("div[data-bin-location-id='#{location_with_only_deleted_bin.id}']")
    end
  end

  describe "DELETE destroy" do
    it "allows deleting an empty location" do
      signed_in_user :root
      delete :destroy, params: { id: empty_bin_location.id.to_s }
      expect { empty_bin_location.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "hard-deletes an empty, unreferenced location" do
      signed_in_user :root
      delete :destroy, params: { id: empty_bin_location.id.to_s }
      expect(BinLocation.unscoped.find_by(id: empty_bin_location.id)).to be_nil
    end

    it "prevents deleting a non-empty location" do
      signed_in_user :root

      expect do
        delete :destroy, params: { id: rack_1_shelf_1.id.to_s }
      end.to raise_error(PermissionError, /Cannot delete non-empty bin location/)

      expect { rack_1_shelf_1.reload }.to_not raise_error
    end

    it "soft-deletes a location whose only bin is already soft-deleted, instead of crashing" do
      signed_in_user :root

      expect do
        delete :destroy, params: { id: location_with_only_deleted_bin.id.to_s }
      end.to_not raise_error

      expect(location_with_only_deleted_bin.reload.deleted_at).to be_present
      expect(bin_in_deleted_only_location.reload).to be_present
    end
  end
end

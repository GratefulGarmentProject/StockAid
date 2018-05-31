require "rails_helper"

describe BinLocationsController, type: :controller do
  let(:empty_bin_location) { bin_locations(:empty_bin_location) }
  let(:rack_1_shelf_1) { bin_locations(:rack_1_shelf_1) }
  let(:empty_bin) { bins(:empty_bin) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }
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

    it "shows the delete button for empty locations" do
      expect(empty_bin_location).to be_deletable
      signed_in_user :root
      get :index
      expect(response.body).to have_selector("div[data-bin-location-id='#{empty_bin_location.id}'] a", text: "Delete")
    end

    it "doesn't the show delete button for non-empty locations" do
      signed_in_user :root
      get :index
      expect(response.body).to_not have_selector("div[data-bin-location-id='#{rack_1_shelf_1.id}'] a", text: "Delete")
    end
  end

  describe "DELETE destroy" do
    it "allows deleting an empty location" do
      signed_in_user :root
      delete :destroy, params: { id: empty_bin_location.id.to_s }
      expect { empty_bin_location.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "prevents deleting a non-empty location" do
      signed_in_user :root

      expect do
        delete :destroy, params: { id: rack_1_shelf_1.id.to_s }
      end.to raise_error(PermissionError, /Cannot delete non-empty bin location/)

      expect { rack_1_shelf_1.reload }.to_not raise_error
    end
  end
end

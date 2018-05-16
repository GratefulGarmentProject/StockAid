require "rails_helper"

describe BinLocationsController, type: :controller do
  let(:empty_bin_location) { bin_locations(:empty_bin_location) }
  let(:rack_1_shelf_1) { bin_locations(:rack_1_shelf_1) }

  describe "GET index" do
    render_views

    it "includes bins with their contents"
    it "shows the delete button for empty locations"
    it "doesn't the show delete button for non-empty locations"
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

class BinLocationsController < ApplicationController
  require_permission :can_view_bins?
  require_permission :can_edit_bins?, except: [:index]
  active_tab "inventory"

  def index
    @bin_locations = BinLocation.includes(bins: :items).order(:rack, :shelf).all.to_a
  end

  def destroy
    current_user.destroy_bin_location(params)
    redirect_to bin_locations_path, flash: { success: "Bin location deleted!" }
  end
end

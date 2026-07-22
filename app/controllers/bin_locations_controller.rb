class BinLocationsController < ApplicationController
  require_permission :can_view_bins?
  require_permission :can_edit_bins?, except: [:index]
  active_tab "inventory"

  def index
    @bin_locations = BinLocation.not_deleted.includes(bins: :items).order(:rack, :shelf).all.to_a
  end

  def edit
    @bin_location = BinLocation.not_deleted.find(params[:id])
  end

  def update
    current_user.update_bin_location(params)
    redirect_to bin_locations_path, flash: { success: "Bin location updated!" }
  end

  def destroy
    current_user.destroy_bin_location(params)
    redirect_to bin_locations_path, flash: { success: "Bin location deleted!" }
  end
end

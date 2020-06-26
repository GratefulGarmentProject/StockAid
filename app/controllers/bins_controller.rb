class BinsController < ApplicationController
  require_permission :can_view_bins?
  require_permission :can_edit_bins?, except: [:index]
  active_tab "inventory"

  def index
    @bins = Bin.not_deleted.includes(:bin_location, :items).all.to_a
  end

  def new; end

  def create
    current_user.create_bin(params)
    redirect_to bins_path, flash: { success: "Bin created!" }
  end

  def edit
    @bin = Bin.not_deleted.find(params[:id])
  end

  def update
    current_user.update_bin(params)
    redirect_to bins_path, flash: { success: "Bin updated!" }
  end

  def destroy
    current_user.destroy_bin(params)
    redirect_to bins_path, flash: { success: "Bin deleted!" }
  end
end

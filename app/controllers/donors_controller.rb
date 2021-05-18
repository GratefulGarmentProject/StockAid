class DonorsController < ApplicationController
  require_permission :can_view_donors?,               only: %i[index edit]
  require_permission :can_create_donors?,             only: %i[new create netsuite_import]
  require_permission :can_update_donors?,             only: :update
  require_permission :can_delete_and_restore_donors?, only: %i[destroy deleted restore]
  require_permission one_of: %i[can_create_donors? can_update_donors?], except: %i[new create netsuite_import]

  active_tab "donors"

  def index
    @donors = Donor.includes(:addresses).active
  end

  def new
    @donor = Donor.new
  end

  def edit
    @redirect_to = Redirect.to(donors_path, params, allow: %i[order users user])
    @donor = Donor.find params[:id]
  end

  def update
    current_user.update_donor params
    redirect_to donors_path
  end

  def netsuite_import
    donor = current_user.create_donor(params, via: :netsuite_import)
    redirect_to edit_donor_path(donor)
  rescue ActiveRecord::RecordInvalid => e
    @show_tab = "netsuite-import"
    @donor = e.record
    flash.now[:error] = e.message
    render :new
  end

  def create
    current_user.create_donor params
    redirect_to donors_path
  rescue ActiveRecord::RecordInvalid => e
    @donor = e.record
    flash.now[:error] = e.message
    render :new
  end

  def destroy
    @donor = Donor.find params[:id]

    begin
      @donor.soft_delete
      flash[:success] = "Donor '#{@donor.name}' deleted!"
    rescue DeletionError => e
      flash[:error] = e.message
    rescue
      flash[:error] = <<-eos
        We were unable to delete the donor as requested.
        Please try again or contact a system administrator.
      eos
    end

    redirect_to donors_path
  end

  def deleted
    @donors = Donor.deleted
  end

  def restore
    @donor = Donor.find params[:id]
    @donor.restore

    redirect_to donors_path(@donor)
  end
end

class DonorsController < ApplicationController
  require_permission :can_view_donors?,               only: [:index, :edit]
  require_permission :can_create_donors?,             only: [:new, :create]
  require_permission :can_update_donors?,             only: :update
  require_permission :can_delete_and_restore_donors?, only: [:destroy, :deleted, :restore]
  require_permission one_of: [:can_create_donors?, :can_update_donors?], except: [:new, :create]

  active_tab "donors"

  def index
    @donors = Donor.active
  end

  def new
    @donor = Donor.new
  end

  def edit
    @redirect_to = Redirect.to(donors_path, params, allow: [:order, :users, :user])
    @donor = Donor.find params[:id]
  end

  def update
    current_user.update_donor params
    redirect_to donors_path
  end

  def create
    current_user.create_donor params
    redirect_to donors_path
  rescue ActiveRecord::RecordInvalid => e
    @donor = e.record
    flash[:error] = e.message
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

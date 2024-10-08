class DonationsController < ApplicationController
  require_permission :can_sync_donations?, only: %i[sync]
  require_permission :can_view_donations?
  require_permission :can_create_donations?, except: %i[index show]
  require_permission :can_close_donations?, only: %i[close closed]
  require_permission :can_delete_and_restore_donations?, only: %i[deleted destroy restore]
  require_permission :can_delete_closed_donations?, only: %i[destroy_closed]
  before_action :authenticate_user!
  active_tab "donations"

  def index
    @donations = Donation.active_with_includes.not_closed.order(id: :desc)
  end

  def closed
    @donations = Donation.closed_with_includes.order(id: :desc)
  end

  def deleted
    @donations = Donation.deleted_with_includes.order(id: :desc)
  end

  def new
    @donation = Donation.new
    @donation.donation_details.build
  end

  def create
    donation = current_user.create_donation(params)

    if params[:button] == "save_and_continue"
      redirect_to edit_donation_path(donation), flash: { success: "Donation created!" }
    else
      redirect_to donations_path, flash: { success: "Donation created!" }
    end
  end

  def show
    @donation = Donation.active_with_includes.find(params[:id])
    redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end

  def edit
    @donation = Donation.active_with_includes.find(params[:id])
    redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end

  def close
    donation = Donation.find params[:id]
    donation.close
    flash[:success] = "Donation '#{donation.id}' closed!"
    redirect_to donations_path
  end

  def update
    donation = current_user.update_donation(params)

    if params[:button] == "save_and_continue"
      redirect_to edit_donation_path(donation), flash: { success: "Donation updated!" }
    else
      redirect_to donation_path(donation), flash: { success: "Donation updated!" }
    end
  end

  def destroy
    @donation = Donation.find params[:id]

    begin
      @donation.soft_delete
      flash[:success] = "Donation '#{@donation.id}' deleted!"
    rescue DeletionError => e
      flash[:error] = e.message
    rescue
      flash[:error] = <<-eos
        We were unable to delete the donation as requested.
        Please try again or contact a system administrator.
      eos
    end

    redirect_to donations_path
  end

  def destroy_closed
    donation = Donation.find(params[:id])
    donation.soft_delete_closed
    flash[:success] = "Closed donation '#{donation.id}' deleted!"
    redirect_to closed_donations_path
  end

  def restore
    donation = Donation.find_by(id: params[:id])

    if donation.present?
      donation.restore
      redirect_to donations_path(@donation)
    else
      redirect_to deleted_donations_path
    end
  end

  def sync
    donation = current_user.sync_donation(params)
    redirect_to donation_path(donation)
  end

  def migrate
    @donations = DonationMigrator.all
  end

  def save_migration
    DonationMigrator.migrate(current_user, params)
    redirect_to migrate_donations_path, flash: { success: "Donations migrated!" }
  end
end

class DonationsController < ApplicationController
  require_permission :can_view_donations?
  require_permission :can_create_donations?, only: [:new, :create]
  before_action :authenticate_user!
  active_tab "donations"

  def index
    @donations = current_user.donations_with_access
  end

  def new
  end

  def create
    current_user.create_donation(params)
    redirect_to donations_path, flash: { success: "Donation created!" }
  end

  def show
    @donation = Donation.includes(:donor, :user, donation_details: { item: :category }).find(params[:id])
    redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end
end

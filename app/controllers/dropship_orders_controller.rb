class DropshipOrdersController < ApplicationController
  require_permission :can_view_dropship_orders?
  require_permission :can_create_dropship_orders?, except: [:index, :show]
  before_action :authenticate_user!
  active_tab "dropship_orders"

  def index
    @dropship_orders = current_user.donations_with_access
  end

  def new
  end

  def create
    # current_user.create_donation(params)
    # redirect_to donations_path, flash: { success: "Donation created!" }

  end

  def show
    # @donation = Donation.includes(:donor, :user, donation_details: { item: :category }).find(params[:id])
    # redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end
end

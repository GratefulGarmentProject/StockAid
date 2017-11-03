class DonationsController < ApplicationController
  require_permission :can_view_donations?
  require_permission :can_create_donations?, only: [:new, :create]
  before_action :authenticate_user!
  active_tab "donations"

  def index
  end

  def new
    @previous_donator_names = Item.paper_trail_version_class
                                  .where(edit_reason: "donation")
                                  .pluck(:edit_source).uniq
                                  .map { |n| n.presence || Reports::ValueByDonor::NO_DONOR }
                                  .sort.map { |e| { name: e } }
  end

  def create
    current_user.create_donation(params)
    redirect_to donations_path, flash: { success: "Donation created!" }
  end
end

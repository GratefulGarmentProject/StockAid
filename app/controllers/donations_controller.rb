class DonationsController < ApplicationController
  require_permission :can_view_donations?
  require_permission :can_create_donations?, only: [:new]
  before_action :authenticate_user!
  active_tab "donations"

  def index
  end

  def new
  end
end

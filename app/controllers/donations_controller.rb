class DonationsController < ApplicationController
  require_permission :can_view_donations?
  before_action :authenticate_user!
  active_tab "donations"

  def index
  end
end

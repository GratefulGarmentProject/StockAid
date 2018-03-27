class BinsController < ApplicationController
  require_permission :can_view_items?
  require_permission :can_view_and_edit_items?, only: [:new, :create]
  active_tab "inventory"

  def index
  end

  def new
  end

  def create
    redirect_to bins_path
  end
end

class OrganizationsController < ApplicationController
  before_action { require_permission one_of: [:can_create_organization?, :can_update_organization?] }

  def index
  end

  def update
    current_user.update_organization params
    redirect_to action: :index
  end

  def create
    current_user.create_organization params
    redirect_to action: :index
  end
end

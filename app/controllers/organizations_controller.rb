class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.all
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

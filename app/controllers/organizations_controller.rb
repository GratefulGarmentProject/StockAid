class OrganizationsController < ApplicationController

  def index
    @organizations = Organization.all
  end

  def create
    organization = Organization.new
    organization.update_attributes params
    if organization.save
      redirect_to 
    else
    end
  end

  def new
  end
end

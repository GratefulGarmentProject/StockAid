class OrganizationsController < ApplicationController
  require_permission :can_create_organization?, only: [:new, :create]
  require_permission :can_delete_and_restore_organizations?, only: [:destroy, :deleted, :restore]
  require_permission one_of: [:can_create_organization?, :can_update_organization?], except: [:new, :create]
  active_tab "organizations"

  def index
    @organizations = current_user.organizations_with_permission_enabled(:can_update_organization_at?,
                                                                        includes: :addresses)
  end

  def new
    @organization = Organization.new
  end

  def edit
    @redirect_to = Redirect.to(organizations_path, params, allow: [:order, :users, :user])
    @organization = Organization.find params[:id]
    raise PermissionError unless current_user.can_update_organization_at?(@organization)
  end

  def update
    current_user.update_organization params
    redirect_to organizations_path
  end

  def create
    current_user.create_organization params
    redirect_to organizations_path
  rescue ActiveRecord::RecordInvalid => e
    @organization = e.record
    render :new
  end

  def destroy
    @organization = Organization.find params[:id]

    begin
      @organization.soft_delete
      flash[:success] = "Organization '#{@organization.name}' deleted!"
    rescue => e
      flash[:error] = e.message
    end

    redirect_to organizations_path
  end

  def deleted
    @organizations = Organization.deleted
  end

  def restore
    @organization = Organization.find_deleted params[:id]
    @organization.restore

    redirect_to organizations_path(@organization)
  end
end

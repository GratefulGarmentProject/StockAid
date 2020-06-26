class OrganizationsController < ApplicationController
  require_permission :can_create_organization?, only: %i[new create]
  require_permission :can_delete_and_restore_organizations?, only: %i[destroy deleted restore]
  require_permission one_of: %i[can_create_organization? can_update_organization?], except: %i[new create]
  active_tab "organizations"

  before_action :set_organization, only: [:edit, :update]

  def index
    @organizations = current_user.organizations_with_permission_enabled(:can_update_organization_at?,
                                                                        includes: :addresses)
  end

  def new
    @organization = Organization.new
  end

  def set_organization
    @organization = Organization.find params[:id]
  end

  def edit
    @redirect_to = Redirect.to(organizations_path, params, allow: %i[order users user])
    raise PermissionError unless current_user.can_update_organization_at?(@organization)
  end

  def update
    raise PermissionError unless current_user.can_update_organization_at?(@organization)

    @organization.update! params.require(:organization).permit(permitted_params)

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
    rescue DeletionError => e
      flash[:error] = e.message
    rescue
      flash[:error] = <<-eos
        We were unable to delete the organization as requested.
        Please try again or contact a system administrator.
      eos
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

  private

  def permitted_params
    params = [
      :external_id, :phone_number, :email, :external_type,
      program_ids: [], addresses_attributes: [:address, :id, :_destroy]
    ]
    params << :county if current_user.can_update_organization_county?
    params << :name if current_user.can_update_organization_name?
    params
  end
end

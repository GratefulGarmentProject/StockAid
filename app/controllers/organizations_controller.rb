class OrganizationsController < ApplicationController
  require_permission :can_create_organization?, only: %i[new create by_program netsuite_import]
  require_permission :can_delete_and_restore_organizations?, only: %i[destroy deleted restore show]
  require_permission one_of: %i[can_create_organization? can_update_organization?],
                     except: %i[new create netsuite_import]
  active_tab "organizations"

  def index
    @organizations = current_user.organizations_with_permission_enabled(:can_update_organization_at?,
                                                                        includes: %i[addresses programs])
  end

  def new
    @organization = Organization.new
  end

  def edit
    @redirect_to = Redirect.to(organizations_path, params, allow: %i[order users user])
    @organization = Organization.find params[:id]
    raise PermissionError unless current_user.can_update_organization_at?(@organization)
  end

  # NOTE: This is currently only accessible from deleted list of organizations
  def show
    @organization = Organization.unscoped.find params[:id]
    raise PermissionError unless current_user.can_update_organization_at?(@organization)
  end

  def update
    current_user.update_organization params
    redirect_to organizations_path
  end

  def netsuite_import
    organization = current_user.create_organization(params, via: :netsuite_import)
    redirect_to edit_organization_path(organization)
  rescue ActiveRecord::RecordInvalid => e
    @show_tab = "netsuite-import"
    @organization = e.record
    flash.now[:error] = e.message
    render :new
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

  def by_program
    @programs = Program.alphabetical.to_a
    @selected_program = Program.find(params.fetch(:program, @programs.first.id))
    ids = OrganizationProgram.where(program: @selected_program).pluck(:organization_id)
    @organizations = Organization.where(id: ids).includes(%i[addresses programs]).to_a
  end

  def restore
    @organization = Organization.find_deleted params[:id]
    @organization.restore

    redirect_to organizations_path(@organization)
  end
end


module Users
  module OrganizationManipulator
    extend ActiveSupport::Concern

    def can_create_organization?
      super_admin?
    end

    def can_update_organization?(organization)
      admin?(organization)
    end

    def can_update_organization_name?
      super_admin?
    end

    def create_organization(params)
      raise PermissionError unless can_create_organization?
      org_params = params.require(:organization)
      Organization.create! org_params.permit(:name, :address, :county, :phone_number, :email)
    end

    def update_organization(params)
      org = Organization.find(params[:id])
      raise PermissionError unless can_update_organization?(org)
      org_params = params.require(:organization)
      if can_update_organization_name?
        org.update! org_params.permit(:name, :address, :county, :phone_number, :email)
      else
        org.update! org_params.permit(:address, :county, :phone_number, :email)
      end
    end
  end
end

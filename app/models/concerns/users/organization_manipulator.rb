
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
      org_params = params.require(:organization).permit(:name, :address, :phone_number, :email, :county)
      Organization.create! org_params
    end

    def update_organization(params)
      org = Organization.find(params[:id])
      raise PermissionError unless can_update_organization?(org)
      org_params = params.require(:organization)
      if can_update_organization_name?
        org.update! org_params.permit(:name, :address, :phone_number, :email, :county)
      else
        org.update! org_params.permit(:address, :phone_number, :email, :county)
      end
    end
  end
end

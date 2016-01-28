module Users
  module OrganizationManipulator
    extend ActiveSupport::Concern

    def can_create_organization?
      super_admin?
    end

    def can_update_organization?(organization)
      admin?(organization)
    end

    def can_update_organization_name?(_organization)
      super_admin?
    end

    def create_organization(params)
      raise PermissionError unless can_create_organization?
      organization = params.require(:organization)
      Organization.create! organization.permit(:name, :address, :phone_number, :email)
    end

    def update_organization(params)
      org = Organization.find(params[:id])
      raise PermissionError unless can_update_organization?(org)
      organization = params.require(:organization)
      if can_update_organization_name?(org)
        org.update! organization.permit(:name, :address, :phone_number, :email)
      else
        org.update! organization.permit(:address, :phone_number, :email)
      end
    end
  end
end

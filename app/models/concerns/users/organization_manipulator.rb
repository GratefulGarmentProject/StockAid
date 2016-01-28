module Users
  module OrganizationManipulator
    extend ActiveSupport::Concern

    def can_create_organization?
      super_admin?
    end

    def can_update_organization?(organization)
      admin?(organization)
    end

    def can_update_organization_name?(organization)
      super_admin?
    end

    def create_organization(params)
      raise PermissionError unless can_create_organization?
      Organization.create! params.slice(:name, :address, :phone_number, :email)
    end

    def update_organization(params)
      org = Organization.find(params[:id])
      raise PermissionError unless can_update_organization?(org)

      if can_update_organization_name?(org)
        org.update! params.slice(:name, :address, :phone_number, :email)
      else
        org.update! params.slice(:address, :phone_number, :email)
      end
    end
  end
end

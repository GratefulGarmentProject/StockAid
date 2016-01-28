module Users
  module OrganizationManipulator
    extend ActiveSupport::Concern

    def can_create_organization?
      super_admin?
    end

    def create_organization(params)
      raise PermissionError unless can_create_organization?
      Organization.create! params.slice(:name, :address, :phone_number, :email)
    end
  end
end

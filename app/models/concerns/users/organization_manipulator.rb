module Users
  module OrganizationManipulator
    extend ActiveSupport::Concern

    def can_create_organization?
      super_admin?
    end

    def can_update_organization?
      admin?
    end

    def can_update_organization_at?(organization)
      admin_at?(organization)
    end

    def can_update_organization_name?
      super_admin?
    end

    def can_update_organization_county?
      super_admin?
    end

    def can_delete_and_restore_organizations?
      super_admin?
    end

    def create_organization(params)
      raise PermissionError unless can_create_organization?
      org_params = params.require(:organization)
      org_params[:addresses_attributes].select! { |_, h| h[:address].present? }
      Organization.create! org_params.permit(:name, :phone_number, :email, :external_type,
                                             addresses_attributes: [:address, :id])
    end
  end
end

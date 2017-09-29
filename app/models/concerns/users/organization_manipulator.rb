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
      Organization.create! org_params.permit(:name, :phone_number, :email, addresses_attributes: [:address, :id])
    end

    def update_organization(params) # rubocop:disable Metrics/AbcSize
      transaction do
        org = Organization.find(params[:id])
        raise PermissionError unless can_update_organization_at?(org)
        org_params = params.require(:organization)
        org_params[:addresses_attributes].select! { |_, h| h[:address].present? }
        permitted_params = [:phone_number, :email, addresses_attributes: [:address, :id, :_destroy]]
        permitted_params << :county if can_update_organization_county?
        permitted_params << :name if can_update_organization_name?
        org.update! org_params.permit(permitted_params)
      end
    end
  end
end

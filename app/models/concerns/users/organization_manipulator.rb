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

    def can_update_organization_external_and_admin_details?
      super_admin?
    end

    def can_delete_and_restore_organizations?
      super_admin?
    end

    def create_organization(params, via: :manual)
      raise PermissionError unless can_create_organization?

      case via
      when :netsuite_import
        Organization.create_from_netsuite!(params)
      when :manual
        Organization.create_and_export_to_netsuite!(params)
      else
        raise "Invalid Organization creation method: #{via}"
      end
    end

    def update_organization(params)
      transaction do
        org = Organization.find(params[:id])
        raise PermissionError unless can_update_organization_at?(org)
        org_params = params.require(:organization)

        org_params[:addresses_attributes]&.select! do |_, h|
          h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? }
        end

        permitted_params = [:phone_number, :email,
                            addresses_attributes: %i[address street_address city state zip id _destroy]]

        if can_update_organization_external_and_admin_details?
          permitted_params.push(:county, :name, :external_id, :external_type)
        end

        org.update! org_params.permit(permitted_params)
      end
    end
  end
end

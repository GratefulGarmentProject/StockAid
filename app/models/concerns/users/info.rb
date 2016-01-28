module Users
  module Info
    extend ActiveSupport::Concern

    def super_admin?
      role == "admin"
    end

    def admin?(organization)
      super_admin? || role_for(organization) == "admin"
    end

    def member?(organization)
      organization_user_for(organization).present?
    end

    def organizations_with_admin_access
      if super_admin?
        @organizations_with_admin_access ||= Organization.all
      else
        organizations.select { |org| admin?(org) }
      end
    end

    def organization_user_for(organization)
      organization_users.find do |org_user|
        org_user.organization_id == organization.id
      end
    end

    def role_for(organization)
      org_user = organization_user_for(organization)
      org_user.role if org_user
    end
  end
end

module Users
  module Info
    extend ActiveSupport::Concern

    def super_admin?
      role == "admin"
    end

    def admin?
      super_admin? || organizations.any? { |org| admin_at?(org) }
    end

    def admin_at?(organization)
      super_admin? || role_at(organization) == "admin"
    end

    def member_at?(organization)
      organization_user_at(organization).present?
    end

    def organizations_with_access
      if super_admin?
        @organizations_with_access ||= Organization.all
      else
        organizations
      end
    end

    def organizations_with_permission_enabled(permission)
      if super_admin?
        organizations_with_access
      else
        organizations_with_access.select do |organization|
          send(permission, organization)
        end
      end
    end

    def organization_user_at(organization)
      organization_users.find do |org_user|
        org_user.organization_id == organization.id
      end
    end

    def role_at(organization)
      org_user = organization_user_at(organization)
      org_user.role if org_user
    end
  end
end

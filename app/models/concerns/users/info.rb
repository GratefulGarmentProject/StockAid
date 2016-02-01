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

    def organizations_with_admin_access
      if super_admin?
        @organizations_with_admin_access ||= Organization.all
      else
        organizations.select { |org| admin_at?(org) }
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

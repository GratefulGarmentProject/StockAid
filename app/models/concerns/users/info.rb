module Users
  module Info
    extend ActiveSupport::Concern

    def root_admin?
      role == "root"
    end

    def super_admin?
      root_admin? || role == "admin"
    end

    def report_admin?
      role == "report"
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

    def show_detailed_exceptions?
      super_admin?
    end

    def can_backup?
      super_admin?
    end

    def can_view_profiler_results?
      super_admin?
    end

    def closed_orders_with_access
      statuses = [:closed]

      if super_admin?
        @closed_orders_with_access ||= Order.by_status_includes_extras(statuses)
      else
        orders.by_status_includes_extras(statuses, %i[order_details tracking_details])
      end
    end

    def canceled_orders_with_access
      statuses = [:canceled]

      if super_admin?
        @canceled_orders_with_access ||= Order.by_status_includes_extras(statuses)
      else
        orders.by_status_includes_extras(statuses, %i[order_details tracking_details])
      end
    end

    def rejected_orders_with_access
      statuses = [:rejected]

      if super_admin?
        @rejected_orders_with_access ||= Order.by_status_includes_extras(statuses)
      else
        orders.by_status_includes_extras(statuses, %i[order_details tracking_details])
      end
    end

    def orders_with_access
      statuses = %i[select_items select_ship_to confirm_order pending
                    approved filled shipped received]
      if super_admin?
        @orders_with_access ||= Order.by_status_includes_extras(statuses)
      else
        orders.by_status_includes_extras(statuses, %i[order_details tracking_details])
      end
    end

    def organizations_with_access
      if super_admin?
        @organizations_with_access ||= Organization.order(name: :asc)
      else
        organizations.order(name: :asc)
      end
    end

    def organizations_with_permission_enabled(permission, options = {})
      organizations = organizations_with_access
      organizations = organizations.includes(options[:includes]) if options.include?(:includes)
      filter_organizations_with_permission_enabled(organizations, permission)
    end

    def filter_organizations_with_permission_enabled(organizations, permission)
      if super_admin?
        organizations
      else
        organizations.select do |organization|
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
      org_user&.role
    end
  end
end

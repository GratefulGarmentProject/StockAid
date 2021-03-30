module Users
  module RevenueStreamManipulator
    extend ActiveSupport::Concern

    def can_view_and_edit_revenue_streams?
      super_admin?
    end

    def can_create_revenue_streams?
      super_admin?
    end

    def can_delete_revenue_streams?
      super_admin?
    end
  end
end

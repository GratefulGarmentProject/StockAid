module Users
  module DropshipOrderManipulator
    extend ActiveSupport::Concern

    def can_view_dropship_orders?
      super_admin?
    end

    def can_create_dropship_orders?
      super_admin?
    end

    def donations_with_access
      if super_admin?
        @donations_with_access ||= DropshipOrder.includes(:vendor, :dropship_order_details, :user).order(id: :desc)
      else
        []
      end
    end
  end
end

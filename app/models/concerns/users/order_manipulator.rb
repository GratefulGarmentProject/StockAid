module Users
  module OrderManipulator
    extend ActiveSupport::Concern

    def can_create_order?
      true
    end

    def can_update_order?
      admin?
    end

    def can_view_orders?
      true
    end
  end
end

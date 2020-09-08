module Users
  module PurchaseManipulator
    extend ActiveSupport::Concern

    def can_view_purchases?
      super_admin?
    end

    def can_create_purchases?
      super_admin?
    end

    def can_update_purchases?
      can_create_purchases?
    end

    def can_cancel_purchases?
      super_admin?
    end
  end
end

module Users
  module PurchaseShipmentManipulator
    extend ActiveSupport::Concern

    def can_destroy_purchase_shipments?
      super_admin?
    end
  end
end

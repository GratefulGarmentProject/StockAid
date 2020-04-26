module Users
  module PurchaseManipulator
    extend ActiveSupport::Concern

    def can_view_purchases?
      super_admin?
    end

    def can_cancel_purchases?
      super_admin?
    end

    def can_create_purchases?
      super_admin?
    end

    def create_purchase(params)
      transaction do
        raise PermissionError unless can_create_purchases?
        Purchase.create_purchase!(self, params)
      end
    end


    def create_order(params)
      raise PermissionError unless can_create_purchases?
      transaction do
        organization = Vendor.find(params[:order][:organization_id])
        purchase = Purchase.new(vendor: vendor,
                                user: self,
                                order_date: Time.zone.now,
                                status: :select_ship_to)
        order.ship_to_name = name unless super_admin?
        OrderDetailsUpdater.new(order, params).update
        order.save!
        order
      end
    end

    def update_purchase(params)
      transaction do
        raise PermissionError unless can_create_purchases?
        purchase = Purchase.find(params[:id])
        purchase.update_purchase!(params)
      end
    end
  end
end

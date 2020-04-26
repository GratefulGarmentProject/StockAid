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
      can_create_purchases?
    end

      # TODO: finally remove these
      # def create_purchase(params)
      #   transaction do
      #     raise PermissionError unless can_create_purchases?
      #     Purchase.create_purchase!(self, params)
      #   end
      # end

      # def update_purchase(params)
      #   transaction do
      #     raise PermissionError unless can_create_purchases?
      #     purchase = Purchase.find(params[:id])
      #     purchase.update_purchase!(params)
      #   end
      # end
  end
end

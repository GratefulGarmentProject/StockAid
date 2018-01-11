module Users
  module ItemManipulator
    extend ActiveSupport::Concern

    def can_view_and_edit_items?
      super_admin?
    end

    def can_view_items?
      true
    end

    def can_view_inventory_reconciliations?
      super_admin?
    end

    def can_edit_inventory_reconciliations?
      super_admin?
    end

    def create_inventory_reconciliation(params)
      raise PermissionError unless can_edit_inventory_reconciliations?
      InventoryReconciliation.create!(user: self, title: params[:title])
    end

    def reconcile_item(params)
      raise PermissionError unless can_edit_inventory_reconciliations?
      raise "Invalid new amount" unless params[:new_amount].present?
      raise "Invalid new amount" unless params[:new_amount] =~ /\A\d+\z/
      raise "Invalid new amount" unless params[:new_amount].to_i >= 0

      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        item = Item.find(params[:item_id])
        reconciliation.reconcile(self, item, params[:new_amount].to_i)
      end
    end
  end
end

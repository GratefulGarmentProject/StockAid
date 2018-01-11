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
  end
end

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

    def can_view_bins?
      super_admin?
    end

    def can_edit_bins?
      super_admin?
    end

    def can_edit_inventory_reconciliation?(reconciliation)
      can_edit_inventory_reconciliations? && !reconciliation.complete
    end

    def create_bin(params)
      raise PermissionError unless can_edit_bins?
      Bin.create_bin!(params)
    end

    def update_bin(params)
      raise PermissionError unless can_edit_bins?
      Bin.update_bin!(params)
    end

    def destroy_bin(params)
      transaction do
        raise PermissionError unless can_edit_bins?
        bin = Bin.not_deleted.find(params[:id])
        raise PermissionError, "Cannot delete non-empty bin!" unless bin.bin_items.empty?
        bin.deleted_at = Time.zone.now
        bin.save!
      end
    end

    def destroy_bin_location(params)
      transaction do
        raise PermissionError unless can_edit_bins?
        bin_location = BinLocation.find(params[:id])
        raise PermissionError, "Cannot delete non-empty bin location!" unless bin_location.bins.empty?
        bin_location.destroy
      end
    end

    def create_inventory_reconciliation(params)
      raise PermissionError unless can_edit_inventory_reconciliations?
      InventoryReconciliation.create!(user: self, title: params[:title])
    end

    def reconcile_item(params) # rubocop:disable Metrics/AbcSize
      raise "Invalid new amount" unless params[:new_amount].present?
      raise "Invalid new amount" unless params[:new_amount] =~ /\A\d+\z/
      raise "Invalid new amount" unless params[:new_amount].to_i >= 0

      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        item = Item.find(params[:item_id])
        reconciliation.reconcile(self, item, params[:new_amount].to_i)
      end
    end

    def reconciliation_comment(params)
      raise PermissionError unless can_view_inventory_reconciliations?
      raise "Content is required!" unless params[:content].present?

      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        raise PermissionError if reconciliation.complete
        reconciliation.reconciliation_notes.create!(user: self, content: params[:content])
      end
    end

    def complete_reconciliation(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        reconciliation.complete = true
        reconciliation.save!
      end
    end

    def update_count_sheet(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        sheet = reconciliation.count_sheets.find(params[:id])
        sheet.update_sheet(params)
        # The count_sheets_controller is going to use the sheet to determine
        # what to redirect to
        sheet
      end
    end
  end
end

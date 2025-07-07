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

    def can_view_item_program_ratios?
      super_admin?
    end

    def can_edit_item_program_ratios?
      super_admin?
    end

    def can_bulk_price_items?
      super_admin?
    end

    def can_edit_inventory_reconciliation?(reconciliation)
      can_edit_inventory_reconciliations? && !reconciliation.complete
    end

    def create_item_program_ratio(params)
      raise PermissionError unless can_edit_item_program_ratios?

      transaction do
        ratio = ItemProgramRatio.new
        ratio_params = params.require(:item_program_ratio).permit(:name, program_ratio: {}, apply_to: {})
        ratio.name = ratio_params[:name]
        ratio.update_program_ratios(ratio_params[:program_ratio])
        ratio.save!
        ratio.apply_to_new_items(ratio_params[:apply_to])
      end
    end

    def update_item_program_ratio(params)
      raise PermissionError unless can_edit_item_program_ratios?

      transaction do
        ratio = ItemProgramRatio.find(params[:id])
        ratio_params = params.require(:item_program_ratio).permit(:name, program_ratio: {}, apply_to: {})
        ratio.name = ratio_params[:name]
        ratio.update_program_ratios(ratio_params[:program_ratio])
        ratio.save!
        ratio.apply_to_new_items(ratio_params[:apply_to])
      end
    end

    def destroy_item_program_ratio(params)
      raise PermissionError unless can_edit_item_program_ratios?

      transaction do
        ratio = ItemProgramRatio.find(params[:id])
        raise PermissionError, "Cannot delete non-empty program ratios!" unless ratio.items.empty?
        ratio.destroy!
      end
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

    def unignore_bin(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        raise PermissionError if reconciliation.complete
        bin_id = params[:bin_id].to_i

        if reconciliation.ignored_bin_ids.include?(bin_id)
          reconciliation.ignored_bin_ids.delete(bin_id)
          reconciliation.save!
          reconciliation.create_missing_count_sheets
        end

        reconciliation
      end
    end

    def reconciliation_comment(params)
      raise PermissionError unless can_view_inventory_reconciliations?
      raise "Content is required!" if params[:content].blank?

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
        raise PermissionError if reconciliation.complete
        # Create misfits if it hasn't been loaded yet
        reconciliation.find_or_create_misfits_count_sheet
        reconciliation.complete_reconciliation
      end
    end

    def delete_reconciliation(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        raise PermissionError if reconciliation.complete

        reconciliation.count_sheets.each do |sheet|
          sheet.count_sheet_details.each(&:destroy!)
          sheet.destroy!
        end

        reconciliation.destroy!
      end
    end

    def update_count_sheet(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        raise PermissionError if reconciliation.complete
        sheet = reconciliation.count_sheets.find(params[:id])
        sheet.update_sheet(params)
        # The count_sheets_controller is going to use the sheet to determine
        # what to redirect to
        sheet
      end
    end

    def delete_count_sheet(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        raise PermissionError if reconciliation.complete
        reconciliation.delete_count_sheet(params[:id])
        reconciliation
      end
    end

    def delete_unnecessary_count_sheets(params)
      transaction do
        reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
        raise PermissionError unless can_edit_inventory_reconciliation?(reconciliation)
        raise PermissionError if reconciliation.complete
        reconciliation.delete_unnecessary_count_sheets
        reconciliation
      end
    end
  end
end

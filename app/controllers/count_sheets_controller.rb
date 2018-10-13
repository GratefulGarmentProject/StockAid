class CountSheetsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  require_permission :can_edit_inventory_reconciliations?, only: [:update]
  active_tab "inventory"

  def index
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
    @reconciliation.create_missing_count_sheets
  end

  def show
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
    @sheet = @reconciliation.count_sheet_for_show(params)
    @sheet.create_missing_count_sheet_details
  end

  def update
    @sheet = current_user.update_count_sheet(params)
    redirect_to after_update_path, flash: { success: "Counts saved!" }
  end

  private

  def after_update_path
    # After completing, it's easier to go back to the rest of the count sheets,
    # except when we are on the misfits page
    if params[:complete].present? && !@sheet.misfits?
      inventory_reconciliation_count_sheets_path(params[:inventory_reconciliation_id], page: params[:page])
    else
      inventory_reconciliation_count_sheet_path(params[:inventory_reconciliation_id], params[:id], page: params[:page])
    end
  end
end

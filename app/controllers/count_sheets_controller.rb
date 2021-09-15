class CountSheetsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  require_permission :can_edit_inventory_reconciliations?, only: %i[update destroy]
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
    redirect_to after_update_path(page: params[:page]), flash: { success: "Counts saved!" }
  end

  def destroy
    reconciliation = current_user.delete_count_sheet(params)
    redirect_to inventory_reconciliation_count_sheets_path(reconciliation), flash: { success: "Count sheet deleted!" }
  end

  private

  def after_update_path(additional_params)
    # After completing, it's easier to go back to the rest of the count sheets,
    # except when we are on the misfits page
    if params[:complete].present? && !@sheet.misfits?
      inventory_reconciliation_count_sheets_path(params[:inventory_reconciliation_id], additional_params)
    else
      inventory_reconciliation_count_sheet_path(params[:inventory_reconciliation_id], params[:id], additional_params)
    end
  end
end

class CountSheetsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  active_tab "inventory"

  def index
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
    @reconciliation.create_missing_count_sheets
  end

  def show
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
    @sheet = @reconciliation.count_sheets.includes(count_sheet_details: :item).find(params[:id])
  end
end

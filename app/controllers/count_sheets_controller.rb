class CountSheetsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  active_tab "inventory"

  def index
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
    @reconciliation.create_missing_count_sheets
  end
end

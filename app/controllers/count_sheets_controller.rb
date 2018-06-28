class CountSheetsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  active_tab "inventory"

  def index
    @reconciliation = InventoryReconciliation.find(params[:inventory_reconciliation_id])
  end
end

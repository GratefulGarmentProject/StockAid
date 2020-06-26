class InventoryReconciliationsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  require_permission :can_edit_inventory_reconciliations?, only: %i[complete create]
  active_tab "inventory"

  def index
    @categories = Category.all
    @reconciliations = InventoryReconciliation.includes(:user).order(created_at: :desc).all
  end

  def create
    reconciliation = current_user.create_inventory_reconciliation(params)
    redirect_to inventory_reconciliation_count_sheets_path(reconciliation),
                flash: { success: "Reconciliation created!" }
  end

  def deltas
    @reconciliation = InventoryReconciliation.find(params[:id])
  end

  def comment
    current_user.reconciliation_comment(params)
    redirect_to inventory_reconciliation_count_sheets_path(params[:id])
  end

  def complete
    current_user.complete_reconciliation(params)
    redirect_to deltas_inventory_reconciliation_path(params[:id])
  end

  def print_prep
    Rack::MiniProfiler.deauthorize_request
    render layout: "blank_print"
  end
end

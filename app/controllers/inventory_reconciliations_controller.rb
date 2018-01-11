class InventoryReconciliationsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  require_permission :can_edit_inventory_reconciliations?, only: [:create, :reconcile]
  active_tab "inventory"

  def index
    @categories = Category.all
    @reconciliations = InventoryReconciliation.includes(:user).order(created_at: :desc).all
  end

  def create
    reconciliation = current_user.create_inventory_reconciliation(params)
    redirect_to inventory_reconciliation_path(reconciliation), flash: { success: "Reconciliation created!" }
  end

  def show
    @categories = Category.all
    @reconciliation = InventoryReconciliation.find(params[:id])
    @category = Category.find(params[:category_id]) if params[:category_id].present?
  end

  def reconcile
    render json: { result: "success" }
  end
end

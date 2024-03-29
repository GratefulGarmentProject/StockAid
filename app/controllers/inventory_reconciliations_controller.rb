class InventoryReconciliationsController < ApplicationController
  require_permission :can_view_inventory_reconciliations?
  require_permission :can_edit_inventory_reconciliations?, only: %i[complete create destroy unignore_bin]
  active_tab "inventory"

  def index
    @categories = Category.all
    @reconciliations = InventoryReconciliation.includes(:user).where(complete: false).order(created_at: :desc).all
  end

  def completed
    @categories = Category.all
    @reconciliations = InventoryReconciliation.includes(:user).where(complete: true).order(created_at: :desc).all
    render :index
  end

  def create
    reconciliation = current_user.create_inventory_reconciliation(params)
    redirect_to inventory_reconciliation_count_sheets_path(reconciliation),
                flash: { success: "Reconciliation created!" }
  end

  def deltas
    @reconciliation = InventoryReconciliation.find(params[:id])
  end

  def ignored_bins
    @reconciliation = InventoryReconciliation.find(params[:id])
    @bins = @reconciliation.ignored_bins.not_deleted.includes(:bin_location, :items).all.to_a
  end

  def unignore_bin
    reconciliation = current_user.unignore_bin(params)
    redirect_to(ignored_bins_inventory_reconciliation_path(reconciliation),
                flash: { success: "Bin successfully unignored!" })
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

  def destroy
    current_user.delete_reconciliation(params)
    redirect_to inventory_reconciliations_path
  end
end

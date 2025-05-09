class PurchasesController < ApplicationController
  require_permission :can_view_purchases?, except: [:next_po_number]
  require_permission :can_create_purchases?, only: %i[new create]
  require_permission :can_update_purchases?, only: %i[edit update]
  require_permission :can_cancel_purchases?, only: %i[cancel]
  require_permission :can_sync_purchases?, only: %i[sync]

  before_action :authenticate_user!

  active_tab "purchases"

  def index
    @purchases = Purchase.includes(:vendor).where(status: PurchaseStatus::OPEN_STATUSES).order(id: :desc)
  end

  def closed
    @purchases = Purchase.includes(:vendor).closed.order(id: :desc)
  end

  def canceled
    @purchases = Purchase.includes(:vendor).canceled.order(id: :desc)
  end

  def new
    @vendors  = Vendor.alphabetize
    @purchase = Purchase.new(status: :new_purchase)
    @purchase.purchase_details.build
  end

  def create
    purchase = Purchase.create!(purchase_params.merge(user_id: current_user.id))
    redirect_after_save "created", purchase
  end

  def edit
    @vendors  = Vendor.alphabetize
    @purchase = Purchase.includes(:vendor, :user, purchase_details: { item: :category }).find(params[:id])
  end

  def update
    Purchase.transaction do
      purchase = Purchase.find(params[:id])
      purchase.assign_attributes(purchase_params)
      purchase.update_status(params[:purchase][:status])
      purchase.save
      redirect_after_save "updated", purchase
    end
  end

  def cancel
    Purchase.transaction do
      purchase = Purchase.find(params[:id])
      raise PermissionError if purchase.closed?
      purchase.update_status(:cancel_purchase)
      purchase.save
      redirect_after_save "canceled", purchase
    end
  end

  def sync
    Purchase.transaction do
      purchase = Purchase.find(params[:id])
      raise PermissionError unless current_user.can_sync_purchase?(purchase)
      NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      redirect_to edit_purchase_path(purchase)
    end
  end

  private

  def purchase_params
    # NOTE: status is missing because the status MUST be changed by using the
    # enum transitions, not by updating the status directly
    @purchase_params ||= params.require(:purchase).permit(
      :purchase_date, :vendor_id, :vendor_po_number, :date, :tax,
      :shipping_cost, :notes,
      revenue_stream_ids:          [],
      purchase_details_attributes: [
        :id, :item_id, :quantity, :cost, :overage_confirmed, :_destroy,
        { purchase_shipments_attributes: %i[id received_date quantity_received _destroy] },
        { purchase_shorts_attributes: %i[id quantity_shorted _destroy] }
      ]
    )
  end

  def redirect_after_save(action, purchase)
    return error_redirect(purchase) if purchase.errors.present?
    return return_redirect(action) if params[:save] == "save-and-close" || purchase.status == "canceled"

    redirect_to edit_purchase_path(purchase), flash: { success: "Purchase #{action}!" }
  end

  def return_redirect(action)
    redirect_to purchases_path, flash: { success: "Purchase #{action}!" }
  end

  def error_redirect(purchase)
    redirect_to edit_purchase_path(purchase), flash: { error: purchase.errors.messages.values.join(" ") }
  end
end

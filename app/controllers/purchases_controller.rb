class PurchasesController < ApplicationController
  require_permission :can_view_purchases?
  require_permission :can_create_purchases?, except: [:index, :show]

  before_action :authenticate_user!

  active_tab "purchases"

  def index
    @purchases = Purchase.includes(:vendor).order(id: :desc)
  end

  def closed
    @purchases = Purchase.includes(:vendor).closed.order(id: :desc)
  end

  def canceled
    @purchases = Purchase.includes(:vendor).canceled.order(id: :desc)
  end

  def new
    @purchase = Purchase.new(status: :new_purchase)
    @vendors = Vendor.all.order(name: :asc)

    render "purchases/status/select_items"
  end

  def create
    # binding.pry
    purchase = Purchase.create!(purchase_params.merge(user: current_user))

    if params[:save] == "save_and_continue"
      redirect_to edit_puchase_path(puchase), flash: { success: "Purchase created!" }
    else
      redirect_to purchases_path, flash: { success: "Purchase created!" }
    end
  end

  def show
    @puchase = Purchase.includes(:vendor, :user, puchase_details: { item: :category }).find(params[:id])
    redirect_to puchases_path unless current_user.can_view_puchase?(@puchase)
  end

  def edit
    @puchase = Purchase.includes(:vendor, :user, puchase_details: { item: :category }).find(params[:id])
    redirect_to puchases_path unless current_user.can_view_puchase?(@puchase)
  end

  def update
    puchase = current_user.update_puchase(params)

    if params[:save] == "save_and_continue"
      redirect_to edit_puchase_path(puchase), flash: { success: "Purchase updated!" }
    else
      redirect_to puchases_path, flash: { success: "Purchase updated!" }
    end
  end

  private

  def purchase_params
    @purchase_params ||= params.require(:purchase).permit(:purchase_date, :vendor_id, :po, :date, :tax, :shipping_cost, :status, purchase_details_attributes: [:item_id, :quantity, :cost])
  end
end

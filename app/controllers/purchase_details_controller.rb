class PurchaseDetailsController < ApplicationController
  require_permission :can_update_purchases?

  before_action :authenticate_user!

  def create
    @purchase = Purchase.find_or_create_by(id: params[:purchase_id])
    @purchase_detail_index = params[:purchase_detail_index]

    render json: {
      content: render_to_string(partial: "purchases/purchase/purchase_detail_row", layout: false, formats: [:html])
    }
  end

  def destroy
    pd = PurchaseDetail.find_by(id: params[:id])
    pd.purchase_shorts.each(&:destroy!)
    @old_id = pd.destroy!.id
  end
end

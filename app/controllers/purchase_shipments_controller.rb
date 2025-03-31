class PurchaseShipmentsController < ApplicationController
  require_permission :can_update_purchases?

  before_action :authenticate_user!

  def create
    @purchase_detail = PurchaseDetail.find_by(id: params[:purchase_detail_id])
    @purchase_detail_index = params[:purchase_detail_index]
    @purchase_shipment_index = params[:purchase_shipment_index]

    render json: {
      content: render_to_string(partial: "purchases/purchase/purchase_shipment_row", layout: false, formats: [:html])
    }
  end

  def short
    @purchase_detail = PurchaseDetail.find_by(id: params[:purchase_detail_id])
    @purchase_detail_index = params[:purchase_detail_index]
    @purchase_short_index = params[:purchase_short_index]

    render json: {
      content: render_to_string(partial: "purchases/purchase/purchase_short_row", layout: false, formats: [:html])
    }
  end

  def destroy
    ps = PurchaseShipment.find_by(id: params[:id])
    @purchase_detail = ps.purchase_detail
    @old_id = ps.destroy!.id
  end
end

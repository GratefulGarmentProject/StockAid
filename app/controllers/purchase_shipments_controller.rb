class PurchaseShipmentsController < ApplicationController
  require_permission :can_destroy_purchase_shipments?

  before_action :authenticate_user!

  def destroy
    purchase_shipment     = PurchaseShipment.find(params[:id])
    purchase_detail       = purchase_shipment.purchase_detail
    @purchase_shipment_id = purchase_shipment.id
    purchase_shipment.destroy!
    @quantity_remaining = purchase_detail.quantity_remaining
  end
end

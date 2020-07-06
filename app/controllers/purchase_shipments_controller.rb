class PurchaseShipmentsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    ps = PurchaseShipment.find_by(id: params[:id])
    @purchase_detail = ps.purchase_detail
    @old_id = ps.destroy!.id
  end
end

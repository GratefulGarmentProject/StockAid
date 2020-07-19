class PurchaseDetailsController < ApplicationController
  before_action :authenticate_user!

  def create
    @purchase = Purchase.find_or_create_by(id: params[:purchase_id])
    @purchase_detail_index = params[:purchase_detail_index]

    render json: {
      content: render_to_string(partial: "purchases/purchase_details_row", layout: false, formats: [:html])
    }
  end

  def destroy
    pd = PurchaseDetail.find_by(id: params[:id])
    @old_id = pd.destroy!.id
  end
end

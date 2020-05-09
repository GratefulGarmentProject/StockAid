class TrackingDetailsController < ApplicationController
  active_tab "tracking_details"

  def new
    @tracking_detail = TrackingDetail.new
  end

  def create
    @tracking_detail = TrackingDetail.new shipment_params

    if @tracking_detail.save
      flash[:success] = "TrackingDetail created!"
      redirect_to @tracking_detail
    else
      flash[:error] = "There was an error saving this shipment."
      render "new"
    end
  end

  def update
    @tracking_detail = TrackingDetail.find(params[:id])
    update_shipment_status!

    @tracking_detail.save

    redirect_to edit_order_path(@tracking_detail.order)
  end

  def destroy
    shipment = TrackingDetail.find(params[:id])
    shipment.destroy

    flash[:success] = "Tracking number #{shipment.tracking_number} for order #{shipment.order_id} deleted!"
    redirect_to :back
  end

  private

  def update_shipment_status!
    return unless params[:status].present?

    @tracking_detail.delivery_date = Time.zone.now if params[:status] == "delivered"
  end

  def shipment_params
    params.require(:shipment).permit(:shipping_carrier, :tracking_number)
  end
end

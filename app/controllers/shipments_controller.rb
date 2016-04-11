class ShipmentsController < ApplicationController
  active_tab "shipments"

  def new
    @shipment = Shipment.new
  end

  def create
    @shipment = Shipment.new shipment_params

    if @shipment.save
      flash[:success] = "Shipment created!"
      redirect_to @shipment
    else
      flash[:error] = "There was an error saving this shipment."
      render "new"
    end
  end

  def update
    @shipment = Shipment.find(params[:id])
    update_shipment_status!

    @shipment.save

    redirect_to edit_order_path(@shipment.order)
  end

  def destroy
    shipment = Shipment.find(params[:id])
    shipment.destroy

    flash[:success] = "Tracking number #{shipment.tracking_number} for order #{shipment.order_id} deleted!"
    redirect_to :back
  end

  private

  def update_shipment_status!
    return unless params[:status].present?

    @shipment.delivery_date = Time.zone.now if params[:status] == "delivered"
  end

  def shipment_params
    params.require(:shipment).permit(:shipping_carrier, :tracking_number)
  end
end

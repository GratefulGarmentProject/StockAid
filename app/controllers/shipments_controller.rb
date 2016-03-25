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
    shipment_status = params[:status].presence
    return unless shipment_status && params[:id]

    shipment = Shipment.find(params[:id])
    shipment.delivery_date = Time.now

    if shipment.save
      redirect_to edit_order_path(shipment.order)
      # format.json { render json: shipment, status: :ok }
    else
      render edit_order_path(shipment.order)
      # format.json { render json: shipment.errors, status: :unprocessable_entity }
    end
  end

  def destroy
    @shipment = Shipment.find(params[:id])
    @order = @shipment.order

    @shipment.destroy

    flash[:success] = "Tracking number #{@shipment.tracking_number} for order #{@order.id} deleted!"
    redirect_to :back
  end

  private

  def shipment_params
    params.require(:shipment).permit(:shipping_carrier, :tracking_number)
  end
end

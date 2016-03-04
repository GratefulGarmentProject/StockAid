class ShipmentsController < ApplicationController
  active_tab "shipments"

  def index
    @shipments = Shipment.all
  end

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

  def track
  end

  def show
    @shipment = Shipment.find(params[:id])
  end

  private

  def shipment_params
    params.require(:shipment).permit(:shipping_carrier, :tracking_number)
  end
end

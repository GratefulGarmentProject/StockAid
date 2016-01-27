class ShipmentsController < ApplicationController
  def index
    @shipments = Shipment.all
  end

  def new
  end

  def create
    @shipment = Shipment.new
    @shipment.tracking_number = params[:tracking_number]
    @shipment.shipping_carrier = params[:shipping_carrier].downcase
    if @shipment.save
      redirect_to action: "show", id: @shipment.id
    else
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      render "create"
    end
  end

  def track
  end

  def show
    @shipment = Shipment.find(params[:id])
  end
end

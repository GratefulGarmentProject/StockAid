class OrdersController < ApplicationController
  def index
    @orders = Order.includes(:organization)
    if params[:status].present?
      @status = params[:status].to_s
      @orders = @orders.for_status(params[:status])
    end
    @orders = @orders.all
  end
end

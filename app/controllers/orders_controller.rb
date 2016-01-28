class OrdersController < ApplicationController
  def index
    @orders = Order.includes(:organization)
    if params[:status].present?
      @status = params[:status].to_s
      @orders = @orders.for_status(params[:status])
    end
    @orders = @orders.all
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    params[:order_details].each do |order_detail_id, quantity|
      found = @order.order_details.detect { |d| d.id.to_s == order_detail_id }
      next unless found
      next if found.quantity == quantity
      found.quantity = quantity
      found.save!
    end

    # [[order_details_id, quantity]]
    redirect_to action: :edit
  end

  def add_item
  end
end

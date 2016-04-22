class OrdersController < ApplicationController
  active_tab "orders"

  def index
  end

  def new
    @order = Order.new status: :select_items
    render "orders/status/select_items"
  end

  def create
    order = current_user.create_order(params)
    redirect_to edit_order_path(order)
  end

  def edit
    @order = Order.find(params[:id])
    @categories = Category.all.map { |cat| [cat.description, cat.id] }
    if @order.order_submitted? && !current_user.super_admin?
      redirect_to orders_path
    elsif Rails.root.join("app/views/orders/status/#{@order.status}.html.erb").exist?
      render "orders/status/#{@order.status}"
    end
  end

  def update
    @order = Order.find(params[:id])
    update_order_details params
    # update_order_details_if_necessary!
    update_ship_to_if_necessary!
    update_order_status_if_necessary!
    update_shipment_information!
    @order.save

    redirect_to edit_order_path(@order)
  end

  private

  def update_order_details params
    return unless params[:order_detail].present?
    params[:order_detail].each do |_row, details|
      existing_order_detail_id = @order.order_details.where(item_id: details[:item_id]).first.id
      if existing_order_detail_id
        existing_order_detail = OrderDetail.find existing_order_detail_id
        existing_order_detail.quantity = details[:quantity]
        existing_order_detail.save
      else
        @order.order_details.new(quantity: details[:quantity], item_id: details[:item_id])
      end
    end
  end

  def process_order_details(order, params)
    params[:order_detail] && params[:order_detail].each do |_row, data|
      next unless data[:item_id].present? && data[:quantity].present?

      order.order_details.new(quantity: data[:quantity], item_id: data[:item_id])
    end
  end

  def update_order_details_if_necessary!
    return unless params[:order_details].present?
    params[:order_details].each do |order_detail_id, order_details|
      puts "order_detail_id = #{order_detail_id} and order_details = #{order_details}"
      found = @order.order_details.detect { |d| d.id.to_s == order_detail_id }
      # puts "found = #{found}"
      # next unless found && found.quantity != quantity
      found.quantity = order_details[:quantity]
      found.save!
    end
  end

  def update_ship_to_if_necessary!
    return unless params[:order].present? && params[:order][:ship_to_address].present?
    @order.ship_to_address = params[:order][:ship_to_address]
  end

  def update_order_status_if_necessary!
    return unless params[:order].present? && params[:order].key?(:status)
    @order.send(params[:order][:status]) if @order.status != params[:order][:status]
  end

  def update_shipment_information! # rubocop:disable Metrics/AbcSize
    return unless params[:tracking_number].present? && params[:shipping_carrier].present?

    params[:tracking_number].each_with_index do |tracking_number, i|
      @order.shipments.create! date: Time.zone.now,
                               tracking_number: tracking_number,
                               shipping_carrier: params[:shipping_carrier][i].to_i
    end
  end
end

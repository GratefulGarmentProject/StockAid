class OrdersController < ApplicationController
  active_tab "orders"

  def index
    find_by_id_if_searching_by_id
    find_by_status_if_filtering_by_status
    find_all_if_showing_all
    @search = params[:search].to_s if params[:search].present?
    @status = params[:status].to_s if params[:status].present?
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    update_order_details_if_necessary!

    redirect_to action: :edit
  end

  def add_item
  end

  def show_order_dialog
    order_id = params["order_id"].to_i
    order = Order.includes(:organization).find(order_id)
    order_details = OrderDetail.includes(:item).for_order(order_id)
    render json: order_json(order, order_details)
  end

  private

  def find_by_id_if_searching_by_id
    @orders = [Order.includes(:organization).find(params[:search].to_i)] if params[:search].to_i != 0
  end

  def find_by_status_if_filtering_by_status
    if params[:status].present? && params[:search].to_i == 0
      @orders = Order.includes(:organization).for_status(params[:status])
    end
  end

  def find_all_if_showing_all
    @orders = Order.includes(:organization).all unless params[:status].present? || params[:search].to_i != 0
  end

  def update_order_details_if_necessary!
    params[:order_details].each do |order_detail_id, quantity|
      found = @order.order_details.detect { |d| d.id.to_s == order_detail_id }
      next unless found
      next if found.quantity == quantity
      found.quantity = quantity
      found.save!
    end
  end

  def order_json(order, order_details)
    {
      order_id: order.id,
      organization_name: CGI.escapeHTML(order.organization.name),
      order_date: order.formatted_order_date,
      status: order.status.titleize,
      order_details: order_details_json(order_details)
    }
  end

  def order_details_json(order_details)
    details_json = []
    order_details.each do |detail|
      json = "{\"description\": \"#{CGI.escapeHTML(detail.item.description)}\",\"quantity\": #{detail.quantity}}"
      details_json << json
    end
    "[#{details_json.join(',')}]"
  end
end

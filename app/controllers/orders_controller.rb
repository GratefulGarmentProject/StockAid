class OrdersController < ApplicationController
  active_tab "orders"

  def index
    @orders = orders_for_user
    if params[:search].to_i != 0
      find_by_id
    elsif params[:status].present?
      find_by_status
    end
    @orders = @orders.all
  end

  def new
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
    order = Order.includes(:organization).includes(:user).find(order_id)
    order_details = OrderDetail.includes(:item).for_order(order_id)
    render json: order_json(order, order_details)
  end

  private

  def orders_for_user
    if current_user.super_admin?
      Order.includes(:organization)
    else
      current_user.orders
    end
  end

  def find_by_id
    @orders = @orders.where(id: params[:search].to_i)
  end

  def find_by_status
    @orders = @orders.for_status(params[:status])
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

  def order_json_user(order)
    {
      name: order.user.name,
      email: order.user.email,
      phone_number: order.user.phone_number,
      address: order.user.address
    }
  end

  def order_json_organization(order)
    {
      name: CGI.escapeHTML(order.organization.name),
      county: order.organization.county
    }
  end

  def order_json(order, order_details)
    {
      order_id: order.id,
      user: order_json_user(order),
      organizaiton: order_json_organization(order),
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

class OrdersController < ApplicationController
  active_tab "orders"

  def index
    @orders = orders_for_user
  end

  def new
    @order = Order.new
    @organizations = if current_user.super_admin?
                       Organization.all.order(name: :asc)
                     else
                       current_user.organizations.order(name: :asc)
                     end
  end

  def create
    order = Order.new(organization_id: params[:order][:organization_id],
                      user_id: current_user.id, order_date: Time.zone.now, status: "pending")

    process_order_details(order, params)

    redirect_to(orders_path) && return if order.save

    render :new
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
    order_details = OrderDetail.select("order_details.*, items.*").includes(:item).joins(:item).for_order(order_id)

    render json: order_json(order, order_details)
  end

  private

  def process_order_details(order, params)
    params[:order_detail].each do |_row, data|
      next unless data[:item_id].present? && data[:quantity].present?

      # create the order detail.
      order.order_details.build(quantity: data[:quantity], item_id: data[:item_id])
    end
  end

  def orders_for_user
    if current_user.super_admin?
      Order.includes(:organization).includes(:order_details)
    else
      current_user.orders.includes(:order_details)
    end
  end

  def update_order_details_if_necessary!
    params[:order_details].each do |order_detail_id, quantity|
      found = @order.order_details.detect { |d| d.id.to_s == order_detail_id }
      next unless found && found.quantity != quantity
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
      organization: order_json_organization(order),
      order_date: order.formatted_order_date,
      status: order.status.titleize,
      order_details: order_details_json(order_details)
    }
  end

  def order_details_json(order_details)
    details_json = []

    order_details.each do |od|
      details_json <<  {
        item_id: od.item.id,
        description: CGI.escapeHTML(od.item.description),
        quantity_ordered: od.quantity,
        quantity_available: od.item.current_quantity
      }
    end

    details_json.sort_by { |a| a[:description] }.to_json
  end
end

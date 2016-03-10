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
    @order = Order.new
    @organizations = current_user.super_admin? ? Organization.all : current_user.organizations
  end

  def create
    order = Order.new(organization_id: params[:order][:organization_id], user_id: current_user.id, order_date: Time.now, status: 'pending')

    params[:order_detail].each do |row, data|
      next unless data[:item_id].present? && data[:quantity].present?

      item = Item.find data[:item_id].to_i
      quantity_requested = data[:quantity].to_i

      # If we have enough items to fullfil this request,
      if item.current_quantity >= quantity_requested
        # create the order detail.
        order.order_details.build(quantity: quantity_requested, item_id: item.id)
      else
        # TODO: need some way to indicate that an item was not filled
        order.order_details.build(quantity: -1, item_id: item.id)
      end
    end

    if order.save
      flash[:success] = "Order created!"
      redirect_to orders_path
    else
      flash[:error] = "There was an error creating your order."
      render :new
    end
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

  def orders_for_user
    if current_user.super_admin?
      Order.includes(:organization).includes(:order_details)
    else
      current_user.orders.includes(:order_details)
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
      organization: order_json_organization(order),
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

class OrdersController < ApplicationController # rubocop:disable Metrics/ClassLength
  active_tab "orders"

  def index
    @orders = orders_for_user
  end

  def new
    @order = Order.new status: :select_items
    @organizations = if current_user.super_admin?
                       Organization.all.order(name: :asc)
                     else
                       current_user.organizations.order(name: :asc)
                     end
    render "orders/status/select_items"
  end

  def create
    order = Order.new(organization_id: params[:order][:organization_id],
                      user_id: current_user.id,
                      order_date: Time.zone.now,
                      status: :select_ship_to)
    order.ship_to_name = current_user.name
    process_order_details(order, params)
    order.save!
    redirect_to(edit_order_path(order))
  end

  def edit
    @order = Order.find(params[:id])
    redirect_to orders_path if @order.being_processed? && current_user.super_admin?
    render "orders/status/#{@order.status}"
  end

  def update
    @order = Order.find(params[:id])
    process_order_details(@order, params)
    update_order_details_if_necessary!
    update_ship_to_if_necessary!
    update_order_status_if_necessary!
    update_shipment_information!
    @order.save

    redirect_to edit_order_path(@order)
  end

  def show_order_dialog
    order_id = params["order_id"].to_i
    order = Order.includes(:organization).includes(:user).find(order_id)
    order_details = OrderDetail.select("order_details.*, items.*").includes(:item).joins(:item).for_order(order_id)

    render json: order_json(order, order_details)
  end

  private

  def process_order_details(order, params)
    params[:order_detail] && params[:order_detail].each do |_row, data|
      next unless data[:item_id].present? && data[:quantity].present?

      order.order_details.build(quantity: data[:quantity], item_id: data[:item_id])
    end
  end

  def orders_for_user
    if current_user.super_admin?
      Order.includes(:organization).includes(:order_details).includes(:shipments)
    else
      current_user.orders.includes(:order_details).includes(:shipments)
    end
  end

  def order_json_user(order)
    {
      name: order.user.name,
      email: order.user.email,
      primary_number: order.user.primary_number,
      secondary_number: order.user.secondary_number,
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

  def update_order_details_if_necessary!
    return unless params[:order_details].present?
    params[:order_details].each do |order_detail_id, quantity|
      found = @order.order_details.detect { |d| d.id.to_s == order_detail_id }
      next unless found && found.quantity != quantity
      found.quantity = quantity
      found.save!
    end
  end

  def update_ship_to_if_necessary!
    return unless params[:order][:ship_to_address].present?
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

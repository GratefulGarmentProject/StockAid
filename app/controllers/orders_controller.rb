class OrdersController < ApplicationController
  require_permission :can_sync_orders?, only: %i[sync]
  active_tab "orders"

  def index
    @orders = current_user.orders_with_access
  end

  def closed
    Organization.unscoped do
      @orders = current_user.closed_orders_with_access.to_a
    end
  end

  def rejected
    Organization.unscoped do
      @orders = current_user.rejected_orders_with_access.to_a
    end
  end

  def canceled
    Organization.unscoped do
      @orders = current_user.canceled_orders_with_access.to_a
    end
  end

  def new
    @order = Order.new status: :select_items
    render "orders/status/select_items"
  end

  def create
    order = current_user.create_order(params)
    redirect_to edit_order_path(order)
  end

  # rubocop:disable Metrics/AbcSize
  def edit
    @order = Order.includes(order_details: :item).find(params[:id])

    if current_user.can_edit_order?(@order)
      if Rails.root.join("app/views/orders/status/#{@order.status}.html.erb").exist?
        render "orders/status/#{@order.status}"
      end
    elsif current_user.can_view_order?(@order)
      render :show
    else
      redirect_to orders_path
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    order = current_user.update_order params
    redirect_to edit_order_path(order)
  end

  def sync
    order = current_user.sync_order(params)
    redirect_to edit_order_path(order)
  end
end

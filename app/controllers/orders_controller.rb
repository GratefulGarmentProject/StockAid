class OrdersController < ApplicationController
  require_permission :can_sync_orders?, only: %i[sync resync_journal_line_items]
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

  def edit
    @order = Order.includes(order_details: %i[item bins]).find(params[:id])

    if current_user.can_edit_order?(@order)
      if Rails.root.join("app/views/orders/status/#{@order.status}.html.erb").exist?
        render "orders/status/#{@order.status}"
      end
    else
      redirect_to orders_path
    end
  end

  def update
    order = current_user.update_order params
    redirect_to edit_order_path(order)
  end

  def sync
    order = current_user.sync_order(params)
    redirect_to edit_order_path(order)
  end

  def resync_journal_line_items
    order, success = current_user.resync_order_journal_line_items(params)

    if success
      redirect_to edit_order_path(order), flash: { success: "Successfully resynced journal line items" }
    else
      redirect_to edit_order_path(order), flash: { error: "Failed to resync journal line items, please check NetSuite errors" }
    end
  end

  def survey_answers
    @order = Order.find(params[:id])
    raise PermissionError unless current_user.can_view_survey_answers?(@order)
  end
end

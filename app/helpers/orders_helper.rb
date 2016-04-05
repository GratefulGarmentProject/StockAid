module OrdersHelper
  def order_has_shipments?(order)
    order.shipments.first.nil?
  end

  def cancel_edit_order_path
    Redirect.to(orders_path, params, allow: :orders)
  end

  def cancel_new_order_path
    Redirect.to(orders_path, params, allow: :orders)
  end
end

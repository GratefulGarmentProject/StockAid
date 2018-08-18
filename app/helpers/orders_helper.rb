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

  def order_detail_quantity_class(order_detail)
    if order_detail.quantity == order_detail.requested_quantity
      "same-quantity"
    elsif order_detail.quantity > order_detail.requested_quantity
      "different-quantity more-quantity"
    else
      "different-quantity less-quantity"
    end
  end

  def show_cancel_button?(order, user)
    !order.new_record? && !order.canceled? && user.can_cancel_order?(order)
  end

  def display_bin_rack_locations(order_detail)
    order_detail.bins.map do |bin|
      "#{bin.label}/#{bin.rack}"
    end.join(", ") if order_detail.bins.any?
  end
end

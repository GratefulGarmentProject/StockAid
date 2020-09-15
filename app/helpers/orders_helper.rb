module OrdersHelper
  def order_has_tracking_details?(order)
    order.tracking_details.first.nil?
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

  def sync_order_button(order)
    css_class = "btn btn-primary"

    unless order.organization.external_id.present?
      css_class += " disabled"
    end

    button = link_to "Sync to NetSuite", sync_order_path(order), class: css_class, data: { toggle: "tooltip" }, method: :post

    if order.organization.external_id.present?
      button
    else
      disabled_title_wrapper("Please set the Organization's NetSuite External id to be able to sync to NetSuite.") { button }
    end
  end

  def show_cancel_button?(order, user)
    !order.new_record? && !order.canceled? && user.can_cancel_order?(order)
  end

  def cancel_order_confirm(order)
    confirm_options = { title: "Canceling Order" }

    if order.synced?
      confirm_options[:message] = "This will <b><em>NOT</em></b> delete the order in NetSuite. Are you sure?".html_safe
    end

    confirm(confirm_options)
  end
end

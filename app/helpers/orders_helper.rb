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

    css_class += " disabled" unless order.organization.synced?

    button = link_to "Sync to NetSuite",
                     sync_order_path(order),
                     class: css_class,
                     data: { toggle: "tooltip" },
                     method: :post

    if order.organization.synced?
      button
    else
      disabled_title_wrapper("Please sync the organization to be able to sync to NetSuite.") { button }
    end
  end

  def close_order_button(order)
    icon = content_tag(:i, "", class: "glyphicon glyphicon-chevron-right")
    button = content_tag(:button,
                         "Close Order".html_safe + icon, # rubocop:disable Rails/OutputSafety
                         type: "submit",
                         name: "order[status]",
                         value: "close",
                         class: "btn btn-primary")

    if order.organization.synced?
      button
    else
      disabled_title_wrapper("Please sync the organization to NetSuite to be able to close this order.") { button }
    end
  end

  def show_cancel_button?(order, user)
    !order.new_record? && !order.canceled? && user.can_cancel_order?(order)
  end

  def cancel_order_confirm(order)
    confirm_options = { title: "Canceling Order" }

    if order.synced?
      # rubocop:disable Rails/OutputSafety
      confirm_options[:message] = "This will <b><em>NOT</em></b> delete the order in NetSuite. Are you sure?".html_safe
      # rubocop:enable Rails/OutputSafety
    end

    confirm(confirm_options)
  end
end

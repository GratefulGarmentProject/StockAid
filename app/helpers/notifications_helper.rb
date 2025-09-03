module NotificationsHelper
  def notification_reference_link(notification)
    return unless @notification.reference

    if @notification.reference.is_a?(Item)
      link_to @notification.reference.description, edit_stock_item_path(@notification.reference)
    else
      "Reference link unable to be determined"
    end
  end
end

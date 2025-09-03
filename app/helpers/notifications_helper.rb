module NotificationsHelper
  def notification_reference_link(notification)
    return unless notification.reference

    case notification.reference
    when Donation
      link_to "Donation #{notification.reference.id}", donation_path(notification.reference, allow_deleted: true)
    when Item
      link_to notification.reference.description, edit_stock_item_path(notification.reference)
    else
      "Reference link unable to be determined"
    end
  end
end

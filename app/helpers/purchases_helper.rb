module PurchasesHelper
  def cancel_edit_purchase_path
    Redirect.to(purchases_path, params, allow: :purchases)
  end

  def cancel_new_purchase_path
    Redirect.to(purchases_path, params, allow: :purchases)
  end

  def purchase_detail_quantity_class(purchase_detail)
    if purchase_detail.quantity == purchase_detail.requested_quantity
      "same-quantity"
    elsif purchase_detail.quantity > purchase_detail.requested_quantity
      "different-quantity more-quantity"
    else
      "different-quantity less-quantity"
    end
  end

  def show_cancel_button?(purchase, user)
    !purchase.new_record? && !purchase.canceled? && user.can_cancel_purchases?
  end

  def vendor_options
    Vendor.active.order('LOWER(name)').map do |vendor|
      [vendor.name, vendor.id, { "data-name" => vendor.name, "data-phone-number" => vendor.phone_number, "data-website" => vendor.website, "data-email" => vendor.email, "data-contact-name" => vendor.contact_name, "data-search-text" => "#{vendor.name} - #{vendor.phone_number} - #{vendor.website} - #{vendor.email} - #{vendor.contact_name}" }]
    end.unshift(["New", "new"])
  end
end
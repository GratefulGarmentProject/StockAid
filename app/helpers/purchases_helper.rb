module PurchasesHelper
  def order_has_shipments?(purchase)
    purchase.shipments.first.nil?
  end

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
end

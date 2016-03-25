module OrdersHelper
  def order_has_shipments?(order)
    order.shipments.first.nil?
  end
end

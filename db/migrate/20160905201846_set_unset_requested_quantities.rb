class SetUnsetRequestedQuantities < ActiveRecord::Migration
  def change
    Order.includes(:order_details).each do |order|
      next if %w(select_items select_ship_to confirm_order).include?(order.status)
      next unless order.order_details.all? { |order_detail| order_detail.requested_quantity == 0 }
      order.order_details.each { |order_detail| order_detail.requested_quantity = order_detail.quantity }
      transaction { order.save! }
    end
  end
end

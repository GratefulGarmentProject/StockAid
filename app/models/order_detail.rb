class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  scope :for_order, ->(order_id) { where(order_id: order_id) }
end

class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  scope :for_order, ->(order_id) { where(order_id: order_id) }

  before_create do
    # Ensure the ordered quantity can be allocated by the item
    if quantity <= item.current_quantity
      item.current_quantity -= quantity
      item.requested_quantity += quantity
      item.save
    end
  end
end

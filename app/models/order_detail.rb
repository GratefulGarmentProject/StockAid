class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  after_commit :update_item

  scope :for_order, ->(order_id) { where(order_id: order_id) }

  def update_item
    # Whenever an OrderDetail is created/modified we want to update that item's
    # requested_quantity value.
    item.requested_quantity = item.pending_requested_quantity
    item.save
  end
end

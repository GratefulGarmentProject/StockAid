class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  before_create :should_update_item_requested_quantity

  scope :for_order, ->(order_id) { where(order_id: order_id) }

  def should_update_item_requested_quantity
    if quantity > 0
      # Update subject item requested quantity.
      item.requested_quantity += quantity
      item.save
      return true
    end

    false
  end
end

class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  after_commit :update_item

  def update_item
    # Whenever an OrderDetail is created/modified we want to update that item's
    # requested_quantity value.
    item.requested_quantity = item.pending_requested_quantity
    item.save
  end

  def to_json
    {
      id: id,
      category_id: item.category_id,
      item_id: item_id,
      quantity: quantity
    }
  end
end

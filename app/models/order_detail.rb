class InvalidOrderDetailsError < StandardError
end

class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  validates :quantity, numericality: { greater_than: 0 }
  validates :quantity, numericality: { less_than: :items_quantity_available }

  after_commit :update_item

  validates :quantity, :value, presence: true

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

  def total_value
    quantity * value
  end

  def items_quantity_available
    item.quantity_available
  end
end

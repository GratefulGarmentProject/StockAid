class InvalidOrderDetailsError < StandardError
end

class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  validates :item_id, :quantity, presence: true
  validates :item_id, numericality: { only_integer: true }, uniqueness: true
  validates :quantity, numericality: {
                                       only_integer: true,
                                       greater_than: 0,
                                       less_than: item.quantity - item.requested_quantity }

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

  def full_value
    quantity * value
  end
end

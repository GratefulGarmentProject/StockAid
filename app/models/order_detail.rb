class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item

  validates :quantity, :value, presence: true

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
end

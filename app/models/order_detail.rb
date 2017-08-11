class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :item, -> { unscope(where: :deleted_at) }

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

  def include_in_packing_slip?
    quantity != 0 || requested_quantity != 0
  end

  def requested_differs_from_quantity?
    quantity != requested_quantity
  end
end

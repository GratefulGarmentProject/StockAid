class InvalidOrderDetailsError < StandardError
end

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

  def self.order_details_valid?(params)
    items = Item.find params[:order][:order_details][:item_id]
    params[:order][:order_details][:item_id].each_with_index { |item_id, index|
      item = items.select { |item| item.id == item_id.to_i }.first
      quantity_available = item.current_quantity - item.requested_quantity
      raise InvalidOrderDetailsError if quantity_available <= 0
      raise InvalidOrderDetailsError if quantity_available < params[:order][:order_details][:quantity][index].to_i
    }
    true
  end
end

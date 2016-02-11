class Item < ActiveRecord::Base
  belongs_to :category
  validates :description, presence: true

  def to_json
    {
      id: id,
      description: description,
      size: size,
      current_quantity: current_quantity,
      requested_quantity: requested_quantity
    }
  end

  def self.create_items_for_sizes(sizes_params, items_params)
    if sizes_params.present?
      sizes_params.keys.map do |size|
        item = new(items_params)
        item.size = size
        item
      end
    else
      [new(items_params)]
    end
  end
end

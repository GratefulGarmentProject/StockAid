class Item < ActiveRecord::Base
  belongs_to :category
  validates :description, presence: true

  # Specify which fields will trigger an audit entry
  has_paper_trail only: [:current_quantity, :description, :category_id, :size]

  attr_accessor :edit_reason, :edit_source

  enum edit_reasons: [:donation, :purchase, :correction]

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

  def mark_event(params)
    return unless changed.include?("current_quantity")
    return unless params["edit_reason"] && params["edit_source"]
    difference = current_quantity.to_i - current_quantity_was.to_i
    set_paper_trail_event(params["edit_reason"], params["edit_source"], difference)
  end

  private

  def set_paper_trail_event(reason, source, difference)
    case reason
    when "donation"
      self.paper_trail_event = "Received donation of #{difference} items: #{source}"
    when "purchase"
      self.paper_trail_event = "Purchased #{difference} items: #{source}"
    when "correction"
      self.paper_trail_event = "Adjusted inventory #{difference} items: #{source}"
    end

    # else ?
    # "Fulfilled request of n items: #{source}."
  end
end

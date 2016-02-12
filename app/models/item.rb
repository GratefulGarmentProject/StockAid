class Item < ActiveRecord::Base
  belongs_to :category
  validates :description, presence: true

  # Specify which fields will trigger an audit entry
  has_paper_trail only: [:current_quantity, :description, :category_id, :size]

  attr_accessor :edit_amount, :edit_method, :edit_reason, :edit_source

  enum edit_reasons: [:donation, :purchase, :correction]
  enum edit_methods: [:add, :subtract, :new_total]

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
    return unless params["edit_amount"] && params["edit_method"] && params["edit_reason"]

    amount = update_quantity(params)
    set_paper_trail_event(params["edit_reason"], params["edit_source"], amount)
  end

  private

  def update_quantity(params)
    amount = params["edit_amount"].to_i
    method = params["edit_method"]

    case method
    when "add"
      self.current_quantity += amount
    when "subtract"
      self.current_quantity -= amount
    when "new_total"
      self.current_quantity = amount
    end

    amount
  end

  def set_paper_trail_event(reason, source, amount)
    case reason
    when "donation"
      self.paper_trail_event = "Donation of #{amount} items. #{source}"
    when "purchase"
      self.paper_trail_event = "Purchase of #{amount} items. #{source}"
    when "correction"
      self.paper_trail_event = "Corrected inventory count to #{amount} items. #{source}"
    end
  end
end

class Category < ActiveRecord::Base
  has_many :items
  validates :description, presence: true

  default_scope { order("upper(description)") }

  def to_json
    {
      id: id,
      description: description,
      items: items.sort_by(&:description).map(&:to_json)
    }
  end

  def value
    items.sum("current_quantity * value")
  end

  def self.to_json
    order(:description).inject_requested_quantities.map(&:to_json).to_json
  end

  def self.inject_requested_quantities
    includes(:items).all.tap do |results|
      Item.inject_requested_quantities(results.map(&:items).flatten)
    end
  end
end

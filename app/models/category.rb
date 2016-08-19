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

  def self.to_json
    includes(:items).order(:description).all.map(&:to_json).to_json
  end

  def value
    items.sum(:value)
  end
end

class Category < ActiveRecord::Base
  has_many :items
  validates :description, presence: true

  def to_json
    { id: id, description: description, items: items.map(&:to_json) }
  end

  def self.sizes_array(sizes_params)
    sizes_params.present? ? sizes_params.split(",").map(&:strip) : []
  end

  def self.to_json
    includes(:items).order(:description).all.map(&:to_json).to_json.html_safe
  end
end

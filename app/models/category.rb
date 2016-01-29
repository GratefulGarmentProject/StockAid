class Category < ActiveRecord::Base
  has_many :items
  validates :description, presence: true

  def self.sizes_array(sizes_params)
    sizes_params.present? ? sizes_params.split(",").map(&:strip) : []
  end
end

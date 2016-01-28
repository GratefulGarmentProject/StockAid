class Category < ActiveRecord::Base
  has_many :items

  validates :description,  presence: true
end

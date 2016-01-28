class Category < ActiveRecord::Base
  has_many :items
  serialize :sizes
end

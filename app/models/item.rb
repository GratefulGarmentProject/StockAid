class Item < ActiveRecord::Base
  belongs_to :category
  has_one :inventory
end

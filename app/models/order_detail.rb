class OrderDetail < ActiveRecord::Base
  belongs_to :order
  has_one :inventory
end

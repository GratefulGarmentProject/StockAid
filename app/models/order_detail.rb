class OrderDetail < ActiveRecord::Base
  belongs_to :order
  has_one :inventory
  has_many :shipments
end

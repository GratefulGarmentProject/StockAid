class OrderDetailProgram < ApplicationRecord
  belongs_to :order_detail
  belongs_to :program
end

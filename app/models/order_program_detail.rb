class OrderProgramDetail < ApplicationRecord
  belongs_to :order
  belongs_to :program
end

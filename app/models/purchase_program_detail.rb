class PurchaseProgramDetail < ApplicationRecord
  belongs_to :purchase
  belongs_to :program
end

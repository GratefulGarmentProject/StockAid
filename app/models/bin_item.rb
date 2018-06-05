class BinItem < ApplicationRecord
  belongs_to :bin
  belongs_to :item
end

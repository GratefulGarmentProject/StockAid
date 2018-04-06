class BinItem < ActiveRecord::Base
  belongs_to :bin
  belongs_to :item
end

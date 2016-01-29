class Item < ActiveRecord::Base
  belongs_to :category

  has_paper_trail
end

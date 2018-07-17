class CountSheetDetail < ApplicationRecord
  belongs_to :count_sheet
  belongs_to :item
end

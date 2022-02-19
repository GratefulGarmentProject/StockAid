class AnnualInventoryPpv < ApplicationRecord
  validates_format_of :year, :with => /[0-9]{4}/
end

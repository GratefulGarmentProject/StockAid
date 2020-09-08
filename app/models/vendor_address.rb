class VendorAddress < ApplicationRecord
  belongs_to :vendor
  belongs_to :address
end

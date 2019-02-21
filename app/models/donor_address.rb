class DonorAddress < ApplicationRecord
  belongs_to :donor
  belongs_to :address
end

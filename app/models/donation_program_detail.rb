class DonationProgramDetail < ApplicationRecord
  belongs_to :donation
  belongs_to :program
end

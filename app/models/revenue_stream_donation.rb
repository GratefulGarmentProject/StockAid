class RevenueStreamDonation < ApplicationRecord
  belongs_to :donation
  belongs_to :revenue_stream
end

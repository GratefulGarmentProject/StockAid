class RevenueStreamPurchase < ApplicationRecord
  belongs_to :purchase
  belongs_to :revenue_stream
end

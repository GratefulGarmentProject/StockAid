class RevenueStream < ApplicationRecord
  include SoftDeletable

  validates :name, uniqueness: true

  has_many :revenue_stream_donations
  has_many :donations, through: :revenue_stream_donations

  has_many :revenue_stream_purchases
  has_many :purchases, through: :revenue_stream_purchases

  scope :alphabetical, -> { order(name: :asc) }
end

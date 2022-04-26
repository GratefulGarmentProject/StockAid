class RevenueStream < ApplicationRecord
  include SoftDeletable

  validates :name, uniqueness: true

  has_many :donations

  has_many :revenue_stream_purchases
  has_many :purchases, through: :revenue_stream_purchases

  scope :alphabetical, -> { order(name: :asc) }

  def self.default_selected_for_donations
    # ID 1 should be in-kind, which is the default selection for donations
    where(id: 1).to_a
  end

  def synced?
    external_id.present?
  end
end

class Vendor < ApplicationRecord
  include SoftDeletable

  has_many :purchases
  has_many :vendor_addresses
  has_many :addresses, through: :vendor_addresses, dependent: :destroy

  accepts_nested_attributes_for :addresses

  validates :name, uniqueness: true, presence: true

  scope :alphabetize, -> { order(name: :asc) }

  def primary_address
    addresses.first&.address
  end
end

class Vendor < ApplicationRecord
  include SoftDeletable

  has_many :purchases
  has_many :vendor_addresses
  has_many :addresses, through: :vendor_addresses, dependent: :destroy

  accepts_nested_attributes_for :addresses

  validates :name, uniqueness: true, presence: true

  scope :alphabetize, -> { order(name: :asc) }

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
  end

  def primary_address
    addresses.first&.address
  end

  def data_search_text
    "#{name} - #{phone_number} - #{website} - #{email} - #{contact_name}"
  end
end

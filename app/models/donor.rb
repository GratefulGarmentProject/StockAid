class Donor < ApplicationRecord
  include SoftDeletable

  validates :name, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  before_validation { self.email = nil if email.blank? }

  has_many :donations, dependent: :destroy
  has_many :donor_addresses, dependent: :destroy
  has_many :addresses, through: :donor_addresses

  accepts_nested_attributes_for :addresses, allow_destroy: true

  alias_attribute :cell_number, :primary_number

  def self.find_any(id)
    unscoped.find(id)
  end

  def sync_status_available?
    external_id.present?
  end

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
  end

  def primary_address
    addresses.first&.address
  end

  def self.permitted_donor_params(params)
    donor_params = params.require(:donor)

    donor_params[:addresses_attributes].select! do |_, h|
      h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? }
    end

    donor_params.permit(:name, :external_id, :email, :external_type,
                        :primary_number, :secondary_number,
                        addresses_attributes: %i[address street_address city state zip id])
  end
end

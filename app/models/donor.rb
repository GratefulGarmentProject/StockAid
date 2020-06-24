class Donor < ApplicationRecord
  include SoftDeletable

  validates :name, uniqueness: true
  validates :external_id, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  before_validation { self.email = nil if email.blank? }

  has_many :donations
  has_many :donor_addresses
  has_many :addresses, through: :donor_addresses

  accepts_nested_attributes_for :addresses, allow_destroy: true

  alias_attribute :cell_number, :primary_number

  def self.find_any(id)
    unscoped.find(id)
  end

  def self.create_or_find_donor(params)
    raise "Missing selected_donor param!" unless params[:selected_donor].present?
    return Donor.find(params[:selected_donor]) if params[:selected_donor] != "new"
    Donor.create!(Donor.permitted_donor_params(params))
  end

  def primary_address
    addresses.first&.address
  end

  def self.permitted_donor_params(params)
    donor_params = params.require(:donor)
    donor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
    donor_params.permit(:name, :external_id, :email, :external_type,
                        :primary_number, :secondary_number,
                        addresses_attributes: [:address, :id])
  end
end

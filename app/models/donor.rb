class Donor < ApplicationRecord
  def self.default_scope
    not_deleted
  end

  validates :name, uniqueness: true
  validates :external_id, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  before_validation { self.email = nil if email.blank? }

  has_many :donations
  has_many :donor_addresses
  has_many :addresses, through: :donor_addresses

  accepts_nested_attributes_for :addresses, allow_destroy: true

  def self.find_any(id)
    unscoped.find(id)
  end

  def self.find_deleted(id)
    deleted.find id
  end

  def self.deleted
    unscoped.where.not(deleted_at: nil)
  end

  def self.not_deleted
    where(deleted_at: nil)
  end

  def soft_delete
    transaction do
      self.deleted_at = Time.zone.now
      save!
    end
  end

  def restore
    self.deleted_at = nil
    save!
  end

  def self.create_or_find_donor(params)
    raise "Missing selected_donor param!" unless params[:selected_donor].present?
    return Donor.find(params[:selected_donor]) if params[:selected_donor] != "new"
    Donor.create!(Donor.permitted_donor_params(params))
  end

  def self.create_from_netsuite!(params)
    netsuite_id = params.require(:external_id).to_i
    netsuite_donor = NetSuite::Records::Customer.get(internal_id: netsuite_id)
    netsuite_address = netsuite_donor.addressbook_list.addressbook[0]

    Donor.create! do |donor|
      if netsuite_donor.is_person
        donor.name = [netsuite_donor.first_name, netsuite_donor.middle_name, netsuite_donor.last_name].compact.join(" ")
      else
        donor.name = netsuite_donor.company_name
      end

      donor.external_id = netsuite_id
      donor.external_type = netsuite_donor.custom_field_list.custentity_npo_constituent_type.value.name
      donor.email = netsuite_donor.email
      donor.phone_number = netsuite_donor.phone || netsuite_donor.mobile_phone

      if netsuite_address
        addr1 = netsuite_address.addressbook_address.addr1
        city = netsuite_address.addressbook_address.city
        state = netsuite_address.addressbook_address.state
        zip = netsuite_address.addressbook_address.zip
        donor.addresses.build(address: "#{addr1}, #{city}, #{state} #{zip}")
      end
    end
  end

  def primary_address
    addresses.first&.address
  end

  def self.permitted_donor_params(params)
    donor_params = params.require(:donor)
    donor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
    donor_params.permit(:name, :external_id, :email, :external_type,
                        :phone_number, addresses_attributes: [:address, :id])
  end
end

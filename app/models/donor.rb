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

    begin
      netsuite_donor = NetSuiteConstituent.by_id(netsuite_id)
    rescue NetSuite::RecordNotFound
      record_for_error = Donor.new(external_id: netsuite_id)
      record_for_error.errors.add(:base, "Could not find NetSuite Constituent with NetSuite ID #{netsuite_id}")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    unless netsuite_donor.donor?
      record_for_error = Donor.new(external_id: netsuite_donor.netsuite_id)
      record_for_error.errors.add(:base, "NetSuite Constituent '#{netsuite_donor.name}' (NetSuite ID #{netsuite_donor.netsuite_id}) is not a donor!")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    Donor.create! do |donor|
      donor.name = netsuite_donor.name
      donor.external_id = netsuite_donor.netsuite_id
      donor.external_type = netsuite_donor.type
      donor.email = netsuite_donor.email
      donor.phone_number = netsuite_donor.phone

      netsuite_address = netsuite_donor.address
      if netsuite_address
        donor.addresses.build(address: netsuite_address)
      end
    end
  end

  def self.create_and_export_to_netsuite!(params)
    transaction do
      donor = Donor.create!(permitted_donor_params(params))

      if params[:save_and_export] == "true"
        NetSuiteConstituent.export_donor(donor)
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

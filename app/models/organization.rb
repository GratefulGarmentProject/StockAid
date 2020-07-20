class Organization < ApplicationRecord
  def self.default_scope
    not_deleted
  end

  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :orders
  has_many :open_orders, -> { where(status: Order.open_statuses) }, class_name: "Order"
  has_many :approved_orders, -> { for_approved_statuses.order(order_date: :desc) }, class_name: "Order"
  has_many :organization_addresses
  has_many :addresses, through: :organization_addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
  validates :name, uniqueness: true

  before_save :add_county
  before_create :add_county

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

  def self.counties
    pluck(:county).uniq
  end

  def self.create_from_netsuite!(params)
    netsuite_id = params.require(:external_id).to_i

    begin
      netsuite_org = NetSuiteConstituent.by_id(netsuite_id)
    rescue NetSuite::RecordNotFound
      record_for_error = Organization.new(external_id: netsuite_id)
      record_for_error.errors.add(:base, "Could not find NetSuite Constituent with NetSuite ID #{netsuite_id}")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    unless netsuite_org.organization?
      record_for_error = Organization.new(external_id: netsuite_org.netsuite_id)
      record_for_error.errors.add(:base, "NetSuite Constituent '#{netsuite_org.name}' (NetSuite ID #{netsuite_org.netsuite_id}) is not an organization!")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    Organization.create! do |organization|
      organization.name = netsuite_org.name
      organization.external_id = netsuite_org.netsuite_id
      organization.external_type = netsuite_org.type
      organization.email = netsuite_org.email
      organization.phone_number = netsuite_org.phone

      netsuite_address = netsuite_org.address
      if netsuite_address
        # netsuite_address will be a hash with the proper address parts
        organization.addresses.build(netsuite_address)
      end
    end
  end

  def self.create_and_export_to_netsuite!(params)
    transaction do
      org_params = params.require(:organization)
      org_params[:addresses_attributes].select! { |_, h| h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? } }
      organization = Organization.create! org_params.permit(:name, :phone_number, :email, :external_id, :external_type,
                                                            addresses_attributes: %i[address street_address city state zip id])

      if params[:save_and_export_organization] == "true"
        NetSuiteConstituent.export_organization(organization)
      end

      organization
    end
  end

  def soft_delete
    ensure_no_open_orders

    transaction do
      organization_users.map(&:destroy!) if organization_users.present?

      self.deleted_at = Time.zone.now
      save!
    end
  end

  def restore
    self.deleted_at = nil
    save!
  end

  def deleted?
    deleted_at != nil
  end

  def primary_address
    addresses.first
  end

  private

  def ensure_no_open_orders
    return if open_orders.blank?

    raise DeletionError, <<-eos
      '#{name}' was unable to be deleted. We found the following open orders:
      #{open_orders.map(&:id).to_sentence}
    eos
  end

  def add_county
    return if county.present? || primary_address.blank?
    if new_record? || changed_attributes.keys.include?("addresses_attributes")
      fetch_geocoding_data do |result|
        self.county = result.address_components.find { |component|
          component["types"].include?("administrative_area_level_2")
        }["short_name"]
      end
    end
  end

  def fetch_geocoding_data
    begin
      result = Geocoder.search(primary_address.to_s).first
    rescue Geocoder::Error => e
      Rails.logger.error("Error fetching geocoding info for #{primary_address}:\n #{e.backtrace}")
    end
    yield result if result
  end
end

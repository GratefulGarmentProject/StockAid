class Organization < ActiveRecord::Base
  def self.default_scope
    not_deleted
  end

  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :orders
  has_many :approved_orders, -> { for_approved_statuses.order(order_date: :desc) }, class_name: "Order"
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
  validates :name, uniqueness: true

  before_save :add_county

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
    return false if open_orders.present?

    transaction do
      organization_users.map(&:destroy!) if organization_users.present?

      self.deleted_at = Time.zone.now
      save
    end
  end

  def restore
    self.deleted_at = nil
    save!
  end

  def self.counties
    pluck(:county).uniq
  end

  def deleted?
    deleted_at != nil
  end

  def primary_address
    addresses.first
  end

  def open_orders
    @_open_orders ||= orders.select { |order| order.open? }
  end

  private


  def add_county
    return if county.present? || primary_address.blank?
    if changed_attributes.keys.include?("addresses_attributes")
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

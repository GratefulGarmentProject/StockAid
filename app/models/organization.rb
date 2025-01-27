class Organization < ApplicationRecord
  def self.default_scope
    not_deleted
  end

  # This is named `organization_county` so we can keep the logic around `county`
  # column without any additional effort, but going forward, reference a
  # separate table tied to a NetSuite ID... eventually, we may want to phase out
  # the old `county` column.
  belongs_to :organization_county, class_name: "County", optional: true
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :orders
  has_many :open_orders, -> { where(status: Order.open_statuses) }, class_name: "Order"
  has_many :approved_orders, -> { for_approved_statuses.order(order_date: :desc) }, class_name: "Order"
  has_many :organization_programs
  has_many :programs, through: :organization_programs
  has_many :organization_addresses
  has_many :addresses, through: :organization_addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
  validates :name, uniqueness: true
  validates :programs, length: { minimum: 1 }

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

  def self.permitted_organization_params(params)
    org_params = params.require(:organization)

    org_params[:addresses_attributes].select! do |_, h|
      h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? }
    end

    org_params.permit(:name, :phone_number, :email, :external_id, :external_type,
                      program_ids: [],
                      addresses_attributes: %i[address street_address city state zip id])
  end

  def to_json
    {
      id: id,
      name: name,
      program_ids: programs.map(&:id)
    }
  end

  def sync_status_available?
    external_id.present?
  end

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
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
end

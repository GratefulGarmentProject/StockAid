class Vendor < ApplicationRecord
  def self.default_scope
    not_deleted
  end

  validates :name, uniqueness: true, presence: true

  has_many :purchases
  has_many :vendor_addresses
  has_many :addresses, through: :vendor_addresses, dependent: :destroy

  accepts_nested_attributes_for :addresses

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

  def primary_address
    addresses.first&.address
  end

  def self.permitted_vendor_params(params)
    vendor_params = params.require(:vendor)
    vendor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
    vendor_params.permit(:name, :phone_number, :website, :email, :contact_name,
                         addresses_attributes: [:address, :id])
  end
end

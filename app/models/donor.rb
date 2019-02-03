class Donor < ApplicationRecord
  def self.default_scope
    not_deleted
  end

  validates :name, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  before_validation { self.email = nil if email.blank? }

  has_many :addresses, through: :donor_addresses

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
    donor_params = params.require(:donor).permit(:name, :address, :email)
    Donor.create!(donor_params)
  end
end

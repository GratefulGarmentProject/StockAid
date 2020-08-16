class Address < ApplicationRecord
  has_many :donor_addresses
  has_many :donors, through: :donor_addresses
  has_many :organization_addresses
  has_many :organizations, through: :organization_addresses

  validate :parts_supercede_whole_address
  validate :all_parts_required_if_any_provided
  before_save :save_from_parts
  after_update :email_address_changes, if: :changed?

  def to_s
    address
  end

  def donor_address?
    DonorAddress.where(address: self).exists?
  end

  def org_address?
    OrganizationAddress.where(address: self).exists?
  end

  def all_parts_present?
    street_address.present? && city.present? && state.present? && zip.present?
  end

  def all_parts_blank?
    street_address.blank? && city.blank? && state.blank? && zip.blank?
  end

  private

  def all_parts_required_if_any_provided
    return if all_parts_present?
    return if all_parts_blank?

    errors.add(:base, "Address parts must all be provided!")
  end

  def parts_supercede_whole_address
    return unless address_changed?
    return unless all_parts_present?

    errors.add(:address, "cannot be changed directly, please change the parts instead!")
  end

  def save_from_parts
    return unless all_parts_present?

    self.address = "#{street_address}, #{city}, #{state} #{zip}"
  end

  def email_address_changes
    return unless org_address?

    admins_to_email = system_admins + org_admins

    admins_to_email.each do |admin|
      AddressChangeMailer.change(admin, organizations.first, changes[:address][0], changes[:address][1]).deliver_now
    end
  end

  def system_admins
    User.where(role: "admin")
  end

  def org_admins
    User.joins(:organization_users).where(
      organization_users: { organization: organizations.first, role: "admin" }
    )
  end
end

class Address < ApplicationRecord
  has_many :donor_addresses
  has_many :donors, through: :donor_addresses
  has_many :organization_addresses
  has_many :organizations, through: :organization_addresses

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

  private

  def email_address_changes
    return if donor_address?

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

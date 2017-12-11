class Address < ActiveRecord::Base
  belongs_to :organization

  after_update :email_address_changes, if: :changed?

  def to_s
    address
  end

  private

  def email_address_changes
    AddressChangeMailer.change(organization, self.changes[:address][0], self.changes[:address][1]).deliver_now
  end
end

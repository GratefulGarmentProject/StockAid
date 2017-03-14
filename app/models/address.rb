class Address < ActiveRecord::Base
  belongs_to :organization

  before_save :mail_if_address_updated

  def to_s
    address
  end

  def last_updated_for(organization)
    where(organization_id: organization.id).sort_by{ |address| address.updated_at }
  end
  private

  def mail_if_address_updated
    return if self.new_record?
    return unless organization_id.present?

    AddressMailer.changed(self.organization)
  end
end

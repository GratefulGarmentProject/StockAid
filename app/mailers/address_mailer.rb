class AddressMailer < ApplicationMailer
  def changed(organization)
    @organization = organization
    @address_updated = organization.addresses.where
    users_to_receive = User.where(role: "admin") +
                        OrganizationUser.where(organization_id: organization.id, role: "admin")

    users_to_receive.each do |recipient|
      @recipient = recipient

      mail to: recipient.email,
           subject: "#{Rails.application.config.site_name} - Address for #{organization.name} changed."
    end
  end
end

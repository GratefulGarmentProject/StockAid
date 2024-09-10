class OrganizationUserMailer < ApplicationMailer
  def invite(organization_user, invited_by)
    @organization_user = organization_user
    @invited_by = invited_by

    mail to: @organization_user.user.email, subject: "You've been added to #{@organization_user.organization.name} " \
                                                     "at #{Rails.application.config.site_name}!"
  end
end

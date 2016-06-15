class UserInvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    mail to: @invitation.email, subject: "You've been invited to #{Rails.application.config.site_name}!"
  end
end

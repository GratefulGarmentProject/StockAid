class UserInvitationMailer < ActionMailer::Base
  def invite(invitation)
    @invitation = invitation
    mail to: @invitation.email, subject: "You've been invited to #{ActionMailer::Base.default_url_options[:host]}!"
  end
end

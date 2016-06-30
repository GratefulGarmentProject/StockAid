class UserEmailChangedMailer < ApplicationMailer
  def changed_email(user)
    @user = user
    mail to: @user.original_email,
         subject: "Your email at #{Rails.application.config.site_name} has changed!"
  end
end

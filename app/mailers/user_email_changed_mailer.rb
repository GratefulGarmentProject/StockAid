class UserEmailChangedMailer < ActionMailer::Base
  def changed_email(user)
    @user = user
    mail to: @user.original_email,
         subject: "Your email at #{ActionMailer::Base.default_url_options[:host]} has changed!"
  end
end

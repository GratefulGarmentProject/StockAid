class AddressChangeMailer < ActionMailer::Base
  layout "admin_mailer_large"

  def change(user, organization, before, after)
    @organization = organization
    @before = before
    @after = after

    mail to: user.email, subject: "Address change for #{@organization.name}"
  end
end

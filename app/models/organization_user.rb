class OrganizationUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  def invite_mailer(invited_by)
    OrganizationUserMailer.invite(self, invited_by)
  end
end

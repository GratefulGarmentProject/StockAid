class OrganizationUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  def invite_mail(invited_by)
    OrganizationUserMailer.invite(self, invited_by)
  end
end

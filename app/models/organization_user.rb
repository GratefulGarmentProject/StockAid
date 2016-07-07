class OrganizationUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  validates :organization_id, uniqueness: { scope: :user_id,
  message: "already has a user with this email" }

  def invite_mailer(invited_by)
    OrganizationUserMailer.invite(self, invited_by)
  end
end

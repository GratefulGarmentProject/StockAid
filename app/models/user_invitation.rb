require "securerandom"

class UserInvitation < ActiveRecord::Base
  belongs_to :invited_by, class_name: "User"
  belongs_to :organization
  before_create :normalize_email
  before_create :create_auth_token
  before_create :set_expiration

  def self.create_or_add_to_organization(invited_by, create_params)
    existing_user = User.find_by_email(create_params[:email].strip.downcase)

    if existing_user
      existing_user.organization_users.create! create_params.slice(:organization, :role)
    else
      invited_by.user_invitations.create! create_params
    end
  end

  private

  def normalize_email
    # The email for users is configured to be stripped and downcased in the
    # Devise config
    self.email = email.strip.downcase
  end

  def create_auth_token
    self.auth_token = SecureRandom.hex(64)
  end

  def set_expiration
    self.expires_at = 2.weeks.from_now
  end
end

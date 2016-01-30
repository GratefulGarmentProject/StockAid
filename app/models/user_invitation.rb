require "securerandom"

class UserInvitation < ActiveRecord::Base
  belongs_to :invited_by, class_name: "User"
  belongs_to :organization
  before_create :normalize_email
  before_create :create_auth_token
  before_create :set_expiration

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

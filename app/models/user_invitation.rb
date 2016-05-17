require "securerandom"
require "set"

class UserInvitation < ActiveRecord::Base
  belongs_to :invited_by, class_name: "User"
  belongs_to :organization
  before_create :normalize_email
  before_create :create_auth_token
  before_create :set_expiration

  def already_member?
    user = User.find_by_email(email)
    user && user.member_at?(organization)
  end

  def expired?
    expires_at < Time.zone.now
  end

  def check(params)
    raise PermissionError if params[:email] != email
    raise PermissionError if params[:auth_token] != auth_token
  end

  def invite_mailer(_invited_by)
    UserInvitationMailer.invite(self)
  end

  def self.find_and_check(params)
    invite = find(params[:id])
    invite.check(params)
    invite
  end

  def self.with_email(email)
    where(email: email.strip.downcase)
  end

  def self.not_expired
    where("expires_at > ?", Time.zone.now)
  end

  def self.convert_to_user(params)
    transaction do
      invite = find_and_check(params)
      raise PermissionError if invite.expired?
      user = User.create! params.permit(:name, :email, :primary_number, :secondary_number,
                                        :address, :password, :password_confirmation)
      user.organization_users.create! organization: invite.organization, role: invite.role
      add_and_expire_other_invites(user, invite, params[:email])
      user
    end
  end

  private_class_method def self.add_and_expire_other_invites(user, invite, email)
    all_invites = UserInvitation.with_email(email).not_expired
    add_other_invites(user, invite, all_invites)
    all_invites.update_all(expires_at: 1.second.ago)
  end

  private_class_method def self.add_other_invites(user, invite, all_invites)
    added_organizations = Set.new([invite.organization_id])

    all_invites.each do |other_invite|
      next if added_organizations.include?(other_invite.organization_id)
      added_organizations << other_invite.organization_id
      user.organization_users.create! organization: other_invite.organization, role: other_invite.role
    end
  end

  def self.create_or_add_to_organization(invited_by, create_params)
    existing_user = User.find_by_email(create_params[:email].strip.downcase)

    if existing_user
      existing_user.organization_users.create! create_params.slice(:organization, :role)
    else
      invited_by.user_invitations.create! create_params
    end
  end

  def self.for_organization(organizations)
    where(organization: organizations)
  end

  def self.valid?(params)
    user_params = params.require(:user)
    user = User.find_by_email user_params[:email]
    # return true if there is no matching email
    return true if user.nil?

    users_organization_ids = user.organizations.map(&:id)
    # return true if user is not at paras[organization_id]
    return true unless users_organization_ids.include?(user_params[:organization_id].to_i)

    users_role = user.organization_users.find_by_organization_id(user_params[:organization_id]).role
    # return true if user doesn't have that role
    return true if users_role != user_params[:role]
    false
  end

  def self.invalid_invitation_alert(params)
    "User invitation is invalid. #{params[:user][:email]} already exists at
#{Organization.find(params[:user][:organization_id]).name} with this role."
  end

  private

  def normalize_email
    # The email for users is configured to be stripped and downcased in the
    # Devise config
    self.email = email.strip.downcase
  end

  def create_auth_token
    self.auth_token = SecureRandom.urlsafe_base64(64)
  end

  def set_expiration
    self.expires_at = 2.weeks.from_now
  end
end

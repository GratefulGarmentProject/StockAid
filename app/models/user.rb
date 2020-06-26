class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable, :lockable
  has_many :organization_users
  has_many :organizations, through: :organization_users
  has_many :user_invitations, foreign_key: :invited_by_id
  has_many :orders, through: :organizations
  has_many :donations

  validates :name, :primary_number, :email, presence: true
  validate :phone_numbers_are_different
  validate :password_is_complex

  include Users::CategoryManipulator
  include Users::DonorManipulator
  include Users::DonationManipulator
  include Users::Info
  include Users::IntegrationManipulator
  include Users::ItemManipulator
  include Users::OrderManipulator
  include Users::OrganizationManipulator
  include Users::ProgramManipulator
  include Users::ReportManipulator
  include Users::UserManipulator

  after_commit :send_pending_notifications

  def deleted?
    !super_admin? && organization_users.empty?
  end

  def valid_password?(password)
    super && !deleted?
  end

  def self.at_organization(orgs)
    joins(:organization_users).where(organization_users: { organization: orgs })
  end

  def self.deleted
    all.select(&:deleted?)
  end

  def self.not_deleted
    all.reject(&:deleted?)
  end

  protected

  def email_updated?
    @email_updated
  end

  def password_updated?
    @password_updated
  end

  def update_details(details)
    @email_updated = details.include?(:email) && email != details[:email]
    @original_email = email
    update! details
  end

  def update_roles(updater, params)
    return unless params[:roles]

    params[:roles].each do |organization_id, role|
      organization = Organization.find(organization_id)
      next unless updater.can_update_user_at?(organization)

      if role.blank?
        organization_user_at(organization).destroy!
      else
        organization_user_at(organization).update! role: role
      end
    end
  end

  def update_password(updater, params)
    return unless params[:user] && params[:user][:password].present?

    if updater == self && !valid_password?(params[:user][:current_password])
      errors.add(:current_password, :invalid, message: "must be valid")
      raise ActiveRecord::RecordInvalid, self
    end

    @password_updated = true
    update! params.require(:user).permit(:password, :password_confirmation)
  end

  def deliver_change_emails
    UserMailer.changed_email(self).deliver_now if email_updated?
    UserMailer.changed_password(self).deliver_now if password_updated?
  end

  def phone_numbers_are_different
    return unless primary_number == secondary_number
    errors.add(:secondary_phone, "can't be the same as the primary phone number")
  end

  def send_devise_notification(notification, *args)
    # If the record is new or changed then delay the
    # delivery until the after_commit callback otherwise
    # send now because after_commit will not be called.
    if new_record? || changed?
      pending_notifications << [notification, args]
    else
      devise_mailer.send(notification, self, *args).deliver_now
    end
  end

  def send_pending_notifications
    pending_notifications.each do |notification, args|
      devise_mailer.send(notification, self, *args).deliver_now
    end

    # Empty the pending notifications array because the
    # after_commit hook can be called multiple times which
    # could cause multiple emails to be sent.
    pending_notifications.clear
  end

  def pending_notifications
    @pending_notifications ||= []
  end

  def password_is_complex
    return if password.nil?
    return if password.match?(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    errors.add(:password, "must have at least a letter, capital letter, and digit")
  end
end

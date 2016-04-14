class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable
  has_many :organization_users
  has_many :organizations, through: :organization_users
  has_many :user_invitations, foreign_key: :invited_by_id
  has_many :orders, through: :organizations

  validates :name, :primary_number, :email, presence: true
  validate :phone_numbers_are_different

  include Users::Info
  include Users::ItemManipulator
  include Users::OrganizationManipulator
  include Users::UserManipulator

  after_commit :send_pending_notifications

  def self.at_organization(orgs)
    joins(:organization_users).where(organization_users: { organization: orgs })
  end

  protected

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
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end

  def send_pending_notifications
    pending_notifications.each do |notification, args|
      devise_mailer.send(notification, self, *args).deliver_later
    end

    # Empty the pending notifications array because the
    # after_commit hook can be called multiple times which
    # could cause multiple emails to be sent.
    pending_notifications.clear
  end

  def pending_notifications
    @pending_notifications ||= []
  end
end

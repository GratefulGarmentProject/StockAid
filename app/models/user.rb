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
  include Users::Info
  include Users::OrganizationManipulator
  include Users::UserManipulator
end

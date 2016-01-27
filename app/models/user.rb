class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable
  has_many :organization_users
  has_many :organizations, through: :organization_users
  include Users::Info
end

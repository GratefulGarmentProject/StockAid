class Organization < ActiveRecord::Base
  has_many :organization_users
  has_many :users, through: :organization_users

  default_scope { order("upper(name)") }
end

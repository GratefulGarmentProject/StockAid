class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  VALID_STATUSES = %i(pending approved rejected filled shipped received).freeze
end

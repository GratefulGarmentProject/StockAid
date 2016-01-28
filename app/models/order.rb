class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details
  has_many :shipments

  VALID_STATUSES = %i(pending approved rejected filled shipped received).freeze
end

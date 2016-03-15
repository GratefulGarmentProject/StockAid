class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details
  has_many :shipments

  # Order processing flowchart
  # pending -> approved -> filled -> shipped -> received
  #        `-> rejected

  enum status: %i(pending approved rejected filled shipped received)

  scope :for_status, ->(status) { where(status: status) }

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end
end

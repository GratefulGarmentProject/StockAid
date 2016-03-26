class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details
  has_many :items, through: :order_details
  has_many :shipments

  # Order processing flowchart
  # pending -> approved -> filled -> shipped -> received -> closed
  #        `-> rejected

  enum status: %i(pending approved rejected filled shipped received closed) do
    event :approve do
      transition :pending => :approved
    end

    event :reject do
      transition :pending => :rejected
    end

    event :hold do
      transition [:approved, :rejected] => :pending
      transition :shipped => :filled
    end

    event :allocate do
      # TODO: allocate the orders detail items here.
      # Order.transaction do
      #   self.allocate_items
      # end

      transition :approved => :filled
    end

    event :ship do
      transition :filled => :shipped
    end

    event :receive do
      transition :shipped => :received
    end

    event :close do
      transition [:rejected, :received] => :closed
    end
  end

  scope :for_status, ->(status) { where(status: status) }

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end
end

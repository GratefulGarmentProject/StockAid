class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details
  has_many :items, through: :order_details
  has_many :shipments

  # Order processing flowchart
  # select_items -> select_ship_to -> confirm_order -/
  # ,----------------------------------------------~'
  # `-> pending -> approved -> filled -> shipped -> received -> closed
  #            `-> rejected

  enum status: { select_items: -3,
                 select_ship_to: -2,
                 confirm_order: -1,
                 pending: 0,
                 approved: 1,
                 rejected: 2,
                 filled: 3,
                 shipped: 4,
                 received: 5,
                 closed: 6 } do
    event :choose_items do
      transition select_items: :select_ship_to
    end

    event :edit_items do
      transition [:select_ship_to, :confirm_order] => :select_items
    end

    event :edit_ship_to do
      transition confirm_order: :select_ship_to
    end

    event :choose_ship_to do
      transition select_ship_to: :confirm_order
    end

    event :submit_order do
      transition confirm_order: :pending
    end

    event :approve do
      transition pending: :approved
    end

    event :reject do
      transition pending: :rejected
    end

    event :hold do
      transition [:approved, :rejected] => :pending
      transition shipped: :filled
    end

    event :allocate do
      # TODO: allocate the orders detail items here.
      # Order.transaction do
      #   self.allocate_items
      # end

      transition approved: :filled
    end

    event :ship do
      transition filled: :shipped
    end

    event :receive do
      transition shipped: :received
    end

    event :close do
      transition [:rejected, :received] => :closed
    end
  end

  scope :for_status, ->(status) { where(status: status) }

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end

  def order_submitted?
    !select_items? && !select_ship_to? && !confirm_order?
  end

  def ship_to_addresses
    [user.address, organization.address]
  end
end

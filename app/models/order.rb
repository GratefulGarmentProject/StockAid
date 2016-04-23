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
    event :confirm_items do
      transition select_items: :select_ship_to
    end

    event :edit_items do
      transition [:select_ship_to, :confirm_order] => :select_items
    end

    event :edit_ship_to do
      transition confirm_order: :select_ship_to
    end

    event :confirm_ship_to do
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

  def self.for_status(status)
    where(status: status)
  end

  def update_details(params)
    order_details.destroy_all
    add_details(params)
  end

  def add_details(params)
    all_items = Item.all
    params[:order][:order_details][:item_id].each_with_index do |item_id, index|
      build_details(params, all_items, item_id, index)
    end
  end

  def add_shipments(params)
    params[:order][:shipments][:tracking_number].each_with_index do |tracking_number, index|
      shipping_carrier = params[:order][:shipments][:shipping_carrier][index]
      shipments.build date: Time.zone.now, tracking_number: tracking_number, shipping_carrier: shipping_carrier.to_i
    end
  end

  def update_status(status)
    return if status.blank?
    return if self.status == status
    send(status)
  end

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end

  def order_submitted?
    !select_items? && !select_ship_to? && !confirm_order?
  end

  def ship_to_addresses
    [user.address, organization.address]
  end

  def order_value
    order_details.map(&:price).inject(0) { |a, e| a + e }
  end

  private

  def build_details(params, all_items, item_id, index)
    quantity = params[:order][:order_details][:quantity][index]
    next unless item_id.present? && quantity.present?
    order_details.build(quantity: quantity.to_i, item_id: item_id.to_i, price: item_price(item_id, all_items))
  end

  def item_price(item_id, items)
    items.find(item_id).price
  end
end

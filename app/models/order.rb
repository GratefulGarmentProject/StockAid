class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details, autosave: true
  has_many :items, through: :order_details
  has_many :shipments

  after_commit :subtract_order_from_inventory

  include OrderStatus

  def add_shipments(params)
    params[:order][:shipments][:tracking_number].each_with_index do |tracking_number, index|
      shipping_carrier = params[:order][:shipments][:shipping_carrier][index]
      shipments.build date: Time.zone.now, tracking_number: tracking_number, shipping_carrier: shipping_carrier.to_i
    end
  end

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end

  def order_submitted?
    !select_items? && !select_ship_to? && !confirm_order?
  end

  def order_uneditable?
    filled? || shipped? || received? || closed?
  end

  def ship_to_addresses
    organization.addresses.map(&:address)
  end

  def ship_to_names
    [user.name.to_s, "#{organization.name} c/o #{user.name}"]
  end

  def to_json
    { id: id, status: status, order_details: order_details.sort_by(&:id).map(&:to_json) }.to_json
  end

  def self.to_json
    includes(:order_details).order(:id).all.map(&:to_json).to_json
  end

  def value
    order_details.map(&:total_value).sum
  end

  def item_count
    order_details.sum(:quantity)
  end

  def subtract_order_from_inventory
    return unless closed?
    order_details.each do |order_detail|
      item = order_detail.item
      item.current_quantity -= order_detail.quantity
      item.save!
    end
  end
end

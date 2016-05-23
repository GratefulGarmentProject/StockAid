class Order < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :order_details
  has_many :items, through: :order_details
  has_many :shipments

  validates :order_details, presence: true

  include OrderStatus

  def update_details(params)
    order_details.destroy_all
    add_details(params)
  end

  def add_details(params)
    params[:order][:order_details][:item_id].each_with_index do |item_id, index|
      quantity = params[:order][:order_details][:quantity][index]
      if params[:order][:order_details][:filled_quantity].present?
        filled_quantity = params[:order][:order_details][:filled_quantity][index]
      end
      if filled_quantity.blank?
        filled_quantity = quantity
      end
      next unless item_id.present? && quantity.present?
      order_details.build(quantity: quantity.to_i, filled_quantity: filled_quantity, item_id: item_id.to_i, price: find_price(params, item_id))
    end
  end

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
    [user.address, organization.address]
  end

  def ship_to_names
    [user.name.to_s, "#{organization.name} c/o #{user.name}"]
  end

  def to_json
    { id: id, order_details: order_details.sort_by(&:id).map(&:to_json) }.to_json
  end

  def self.to_json
    includes(:order_details).order(:id).all.map(&:to_json).to_json
  end

  def order_value
    order_details.map(&:price).inject(0) { |a, e| a + e }
  end

  private

  def find_price(params, item_id)
    @cache ||= {}
    return @cache[item_id.to_i].price if @cache[item_id.to_i]
    Item.where(id: params[:order][:order_details][:item_id]).find_each { |item| @cache[item.id] = item }
    @cache[item_id.to_i].price
  end
end

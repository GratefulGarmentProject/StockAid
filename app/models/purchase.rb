class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :vendor
  belongs_to :vendor_unscoped, -> { unscope(:where) }, class_name: "Vendor", foreign_key: :vendor_id

  has_many :purchase_details

  include PurchaseStatus

  def self.for_vendor(vendor)
    where(vendor: vendor)
  end

  def self.create_purchase!(creator, params)
    valid_params = validate_purchase_params(params)

    vendor = Vendor.find_by(id: valid_params[:vendor_id])
    raise "No vendor found with id #{valid_params[:vendor_id]}" unless vendor

    purchase = Purchase.create!(
      vendor: vendor,
      user: creator,
      po: valid_params[:po],
      tax: valid_params[:tax],
      date: valid_params[:date],
      status: valid_params[:status],
      shipping_cost: valid_params[:shipping_cost],
    )

    purchase.add_details_to_purchase!(valid_params)
    purchase
  end

  def update_purchase!(params)
    valid_params = validate_purchase_params(params)

    vendor = Vendor.find(valid_params[:vendor_id])

    self.vendor = vendor
    self.po = valid_params[:po],
    self.tax = valid_params[:tax],
    self.date = valid_params[:date],
    self.status = valid_params[:status],
    self.shipping_cost = valid_params[:shipping_cost]
    save!

    add_details_to_purchase!(valid_params)
    self
  end

  def add_details_to_purchase!(params)
    return self if skip_adding_purchase_details?

    purchase_detail_params = valid_purchase_params.require(:purchase_details)
    item_ids = purchase_detail_params.require(:item_id)
    quantities = purchase_detail_params.require(:quantity)

    item_ids.each_with_index do |item_id, i|
      quantity = quantities[i].to_i
      item = Item.find(item_id)

      purchase_details.create!(
        item: item,
        quantity: quantity,
        value: item.value
      )
    end
  end

  def formatted_purchase_date
    purchase_date&.strftime("%-m/%-d/%Y")
  end

  def cost
    purchase_details.map(&:line_cost).sum
  end

  def item_count
    purchase_details.map(&:quantity).sum
  end

  def valid_purchase_params(params)
    @purchase_params ||= params.require(:purchase).permit(:vendor_id, :po, :date, :tax, :shipping_cost, :status, purchase_details: [item_id: [], quantity: [], cost: []])
  end

  private

  def skip_adding_purchase_details?
    return true if valid_purchase_params.dig(:purchase_details, :item_id).blank?
    false
  end
end

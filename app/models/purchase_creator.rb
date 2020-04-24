class PurchaseCreator
  attr_accessor :purchase_params
  def initialize(purchase_params)
    @purchase_params = purchase_params
  end

  def create_purchase!(creator)
    vendor = Vendor.find_by(id: purchase_params[:vendor_id])
    raise "No vendor found with id #{purchase_params[:vendor_id]}" unless vendor

    purchase = Purchase.create!(
      vendor_id: vendor.id,
      user: creator,
      po: purchase_params[:po],
      tax: purchase_params[:tax],
      date: purchase_params[:date],
      status: purchase_params[:status],
      shipping_cost: purchase_params[:shipping_cost],
    )

    purchase.add_details_to_purchase!(purchase_params)
    purchase
  end

  # def update_purchase!

  #   vendor = Vendor.find(purchase_params[:vendor_id])

  #   self.vendor = vendor
  #   self.po = purchase_params[:po],
  #   self.tax = purchase_params[:tax],
  #   self.date = purchase_params[:date],
  #   self.status = purchase_params[:status],
  #   self.shipping_cost = purchase_params[:shipping_cost]
  #   save!

  #   add_details_to_purchase!(purchase_params)
  #   self
  # end

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
end

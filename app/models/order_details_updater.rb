class OrderDetailsUpdater
  attr_reader :order, :params

  def initialize(order, params)
    @order = order
    @params = params
  end

  def update
    return unless new_order_details_present?
    update_exsisting
    zero_out
    add_new_details
  end

  private

  def order_status
    if params[:order].present? && params[:order][:status].present?
      params[:order][:status]
    else
      "unknown"
    end
  end

  def new_order_details_present?
    params[:order].present? && params[:order][:order_details].present?
  end

  def new_item_ids
    @new_item_ids ||= params[:order][:order_details][:item_id].map(&:to_i)
  end

  def new_quantities
    @new_quantities ||= params[:order][:order_details][:quantity].map(&:to_i)
  end

  def new_order_details_hash
    @new_order_details_hash ||= new_item_ids.zip(new_quantities).to_h
  end

  def original_item_ids
    @original_item_ids ||= order_details.map(&:item_id)
  end

  def order_details
    order.order_details
  end

  def item_ids_to_update
    @item_ids_to_update ||= original_item_ids & new_item_ids
  end

  def item_ids_to_zero
    @item_ids_to_zero ||= original_item_ids - item_ids_to_update
  end

  def item_ids_to_add
    @item_ids_to_add ||= new_item_ids - item_ids_to_update
  end

  def order_details_hash
    @order_details_hash ||= order_details.index_by(&:item_id)
  end

  def update_exsisting
    item_ids_to_update.each do |item_id|
      order_details_hash[item_id].quantity = new_order_details_hash[item_id]
    end
  end

  def zero_out
    item_ids_to_zero.each do |item_id|
      order_details_hash[item_id].quantity = 0
    end
  end

  def add_new_details
    item_ids_to_add.each do |item_id|
      order_details.build(quantity: new_order_details_hash[item_id],
                          item_id: item_id,
                          value: find_value(item_id))
    end
  end

  def find_value(item_id)
    @cache ||= {}
    return @cache[item_id].value if @cache[item_id]
    Item.where(id: params[:order][:order_details][:item_id]).find_each { |item| @cache[item.id] = item }
    @cache[item_id].value
  end
end

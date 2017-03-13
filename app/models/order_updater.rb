class OrderUpdater
  attr_reader :order, :params

  def initialize(order, params)
    @order = order
    @params = params
  end

  def update
    update_details
    update_notes
    update_shipments
    update_address
    update_status
  end

  private

  def update_details
    OrderDetailsUpdater.new(order, params).update
  end

  def update_notes
    OrderNotesUpdater.new(order, params).update
  end

  def update_shipments
    return unless params[:order].present? && params[:order][:shipments].present?
    order.add_shipments(params)
  end

  def update_address
    return unless params[:order].present? && params[:order][:ship_to_address].present?
    order.ship_to_address = params[:order][:ship_to_address]
  end

  def update_status
    return unless params[:order].present? && params[:order][:status].present?
    order.update_status(params[:order][:status], params)
  end
end

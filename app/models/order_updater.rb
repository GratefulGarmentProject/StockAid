class OrderUpdater
  attr_reader :order, :params

  def initialize(order, params)
    @order = order
    @params = params
  end

  def update
    update_notes
    update_details
    update_tracking_details
    update_address
    update_status
  end

  private

  def update_details
    OrderDetailsUpdater.new(order, params).update
  end

  def update_notes
    return unless params[:order].present? && params[:order].include?(:notes)
    order.notes = params[:order][:notes]
  end

  def update_tracking_details
    return unless params[:order].present? && params[:order][:tracking_details].present?
    order.add_tracking_details(params)
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

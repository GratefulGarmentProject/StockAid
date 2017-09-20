class OrderNotesUpdater
  attr_reader :order, :params, :notes

  def initialize(order, params)
    @order = order
    @params = params
  end

  def update
    return unless new_order_notes_present?
    @notes = params[:order][:order_notes][:text]
    add_new_details
  end

  private

  def add_new_details
    notes.each do |note|
      OrderNote.create(order: order, text: note)
    end
  end

  def new_order_notes_present?
    params[:order].present? && params[:order][:order_notes].present?
  end
end

class OrderNotesUpdater
  attr_reader :order, :params, :notes

  def initialize(order, params)
    @order = order
    @params = params
  end

  def update
    return unless new_order_notes_present?
    @notes = params[:order][:order_notes][:text]
    # update_exsisting
    # zero_out
    add_new_details
  end

  private

  def add_new_details
    notes.each do |note|
      OrderNote.create(order: order, text: note)
    end
  end

  # def note_ids_to_update
  #   @note_ids_to_update ||= original_note_ids & new_note_ids
  # end

  # def original_note_ids
  #   @original_note_ids ||= order_notes.map(&:id)
  # end

  # def order_notes
  #   order.order_notes
  # end

  def new_order_notes_present?
    params[:order].present? && params[:order][:order_notes].present?
  end

  # def zero_out
  #   note_ids_to_zero.each do |note_id|
  #     order_notes_hash[note_id].quantity = 0
  #   end
  # end
end

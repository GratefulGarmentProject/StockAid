class OrderNotesController < ApplicationController
  def destroy
    order_note = OrderNote.find(params[:id])
    order_note.destroy

    flash[:success] = "Order note: #{order_note.text} for order #{order_note.order_id} deleted!"
    redirect_to :back
  end
end

class OrderNotesController < ApplicationController
  def destroy
    order_note = OrderNote.find(params[:id])
    order_note.destroy!

    redirect_to :back, flash: { success: "Order note successfully deleted!" }
  end
end

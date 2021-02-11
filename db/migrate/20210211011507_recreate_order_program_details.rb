class RecreateOrderProgramDetails < ActiveRecord::Migration[5.1]
  def up
    OrderProgramDetail.delete_all

    # Iterate each order and create the order_program_details, but don't
    # load all the orders into memory at once since it will be a fair amount
    # of orders
    closed_ids = Order.where(status: :closed).pluck(:id)

    closed_ids.each do |order_id|
      order = Order.find(order_id)
      order.create_values_for_programs
    end
  end

  def down
    # Nothing to do
  end
end

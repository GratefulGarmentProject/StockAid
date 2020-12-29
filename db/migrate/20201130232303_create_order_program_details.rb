class CreateOrderProgramDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :order_program_details do |t|
      t.integer :order_id, null: false
      t.integer :program_id, null: false
      t.decimal :value, precision: 8, scale: 2
      t.timestamps
      t.index [:order_id, :program_id], unique: true
      t.index :program_id
    end

    reversible do |dir|
      dir.up do
        # Iterate each order and create the order_program_details, but don't
        # load all the orders into memory at once since it will be a fair amount
        # of orders
        closed_ids = Order.where(status: :closed).pluck(:id)

        closed_ids.each do |order_id|
          order = Order.find(order_id)
          order.create_values_for_programs
        end
      end

      dir.down do
        # Nothing to do
      end
    end
  end
end

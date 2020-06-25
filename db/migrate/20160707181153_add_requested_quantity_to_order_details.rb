class AddRequestedQuantityToOrderDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :order_details, :requested_quantity, :integer, { default: 0, null: false }
  end
end

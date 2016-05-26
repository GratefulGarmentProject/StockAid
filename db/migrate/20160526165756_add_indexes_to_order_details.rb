class AddIndexesToOrderDetails < ActiveRecord::Migration
  def change
    add_index :order_details, [:order_id, :item_id], unique: true
    # change_column_null(:order_details, [:item_id, :quantity], true)
  end
end

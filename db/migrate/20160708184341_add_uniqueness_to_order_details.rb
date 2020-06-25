class AddUniquenessToOrderDetails < ActiveRecord::Migration[5.0]
  def change
    add_index :order_details, [:order_id, :item_id], unique: true
  end
end

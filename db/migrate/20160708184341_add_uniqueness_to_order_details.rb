class AddUniquenessToOrderDetails < ActiveRecord::Migration
  def change
    add_index :order_details, [:order_id, :item_id], unique: true
  end
end

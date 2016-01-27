class AddOrderDetailsIndex < ActiveRecord::Migration
  def change
    add_index :order_details, :order_id
    add_foreign_key :order_details, :inventories
  end
end

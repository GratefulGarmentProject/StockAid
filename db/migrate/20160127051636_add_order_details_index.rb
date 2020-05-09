class AddOrderDetailsIndex < ActiveRecord::Migration[5.0]
  def change
    # In rails 5.2 the creation of references in table creation defaults to create this index
    # 20160127010428_create_order_details
    # add_index :order_details, :order_id
    add_foreign_key :order_details, :inventories
  end
end

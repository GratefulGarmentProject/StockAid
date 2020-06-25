class DropInventoryAndAddQuantitiesToItem < ActiveRecord::Migration[5.0]
  def up
    remove_reference :order_details, :inventory, foreign_key: true
    add_reference :order_details, :item, foreign_key: true, null: false
    drop_table :inventories
    add_column :items, :current_quantity, :integer, default: 0, null: false
    add_column :items, :requested_quantity, :integer, default: 0, null: false
  end

  def down
    create_table :inventories do |t|
      t.integer :current_quantity, null: false, default: 0
      t.integer :requested_quantity, null: false, default: 0
      t.references :item

      t.timestamps null: false
    end
    remove_column :items, :current_quantity
    remove_column :items, :requested_quantity
    remove_reference :order_details, :item, foreign_key: true
    add_reference :order_details, :inventory, foreign_key: true
  end
end

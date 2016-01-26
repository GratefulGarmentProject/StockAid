class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :current_quantity
      t.integer :requested_quantity
      t.references :item

      t.timestamps null: false
    end
  end
end

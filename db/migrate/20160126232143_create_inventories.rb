class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.integer :current_quantity, null: false, default: 0
      t.integer :requested_quantity, null: false, default: 0
      t.references :item

      t.timestamps null: false
    end
  end
end

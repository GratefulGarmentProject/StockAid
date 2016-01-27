class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.references :order, null: false
      t.references :inventory, null: false
      t.column :quantity, :integer, null: false
      t.timestamps null: false
    end
  end
end

class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :order_id
      t.string :tracking_number
      t.string :shipping_carrier
      t.decimal :cost
      t.date :date
      t.date :delivery_date

      t.timestamps null: false
    end
  end
end

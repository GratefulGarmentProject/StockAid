class CreateVendorsDropshipOrdersAndDropshipDetailsTables < ActiveRecord::Migration[5.0]
  def change
    create_table :vendors do |t|
      t.references :address, foreign_key: true,             null: false

      t.string     :name,                                   null: false
      t.string     :email
      t.string     :phone

      t.timestamps null: false

      t.index [:name], unique: true
      t.index [:email], unique: true
    end

    create_table :dropship_orders do |t|
      t.references :vendor,         foreign_key: true,      null: false

      t.string     :vendor_po
      t.datetime   :order_date,                             null: false
      t.decimal    :tax,            precision: 8, scale: 2, null: false
      t.decimal    :shipping_cost,  precision: 8, scale: 2, null: false
      t.text       :notes

      t.timestamps null: false

      t.index [:vendor_po]
      t.index [:order_date]
    end

    create_table   :dropship_details do |t|
      t.references :dropship_order, foreign_key: true,      null: false
      t.references :item,           foreign_key: true,      null: false

      t.integer    :quantity,                               null: false
      t.decimal    :cost,           precision: 8, scale: 2

      t.timestamps null: false

      t.index [:dropship_order_id, :item_id]
    end
  end
end

class AddPurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases do |t|
      t.references :user, foreign_key: true, null: false
      t.references :vendor, foreign_key: true, null: false
      t.string :po, null: false
      t.integer :status, null: false
      t.datetime :purchase_date, null: false
      t.decimal :shipping_cost, precision: 8, scale: 2, default: 0
      t.decimal :tax, precision: 8, scale: 2, default: 0
      t.timestamps null: false
    end

    create_table :purchase_details do |t|
      t.references :purchase, foreign_key: true, null: false
      t.references :item, foreign_key: true, null: false
      t.integer :quantity, null: false
      t.decimal :cost, precision: 8, scale: 2
      t.decimal :variance, precision: 8, scale: 2
      t.timestamps null: false
      t.index [:purchase_id, :item_id]
    end
  end
end

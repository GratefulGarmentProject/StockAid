class AddPurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases do |t|
      t.references :user, foreign_key: true, null: false
      t.references :vendor, foreign_key: true, null: false
      t.string :po, null: false, comment: "Purchase Order, calculated"
      t.integer :status, null: false, comment: "Status order, state machine tracked"
      t.date :purchase_date, null: false
      t.decimal :shipping_cost, precision: 8, scale: 2, default: 0
      t.decimal :tax, precision: 8, scale: 2, default: 0
      t.timestamps null: false
    end

    create_table :purchase_details do |t|
      t.references :purchase, foreign_key: true, null: false
      t.references :item, foreign_key: true, null: false
      t.integer :quantity, null: false, comment: "The quantity of items ordered"
      t.decimal :cost, precision: 8, scale: 2, comment: "Cost per item"
      t.decimal :variance, precision: 8, scale: 2, comment: "Variance between the Item value and the purchase item cost, calculated"
      t.timestamps null: false
      t.index [:purchase_id, :item_id]
    end

    create_table :purchase_shipments do |t|
      t.references :purchase_detail, foreign_key: true
      t.integer :quantity_received, comment: "how many of the item came in the shipment"
      t.date :received_date, comment: "the date the shipment was received"
      t.timestamps
    end
  end
end

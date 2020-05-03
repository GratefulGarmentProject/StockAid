class CreatePurchaseShipments < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_shipments do |t|
      t.references :purchase_detail, foreign_key: true
      t.integer :number, comment: "an increasing integer for each purchase shipment"
      t.string :tracking_number, comment: "the vendor's tracking number for this shipment"
      t.datetime :received_at
      t.integer :quantity_received

      t.timestamps
    end
  end
end

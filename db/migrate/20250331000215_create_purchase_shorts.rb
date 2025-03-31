class CreatePurchaseShorts < ActiveRecord::Migration[6.1]
  def change
    create_table :purchase_shorts do |t|
      t.references :purchase_detail, foreign_key: true, null: false
      t.integer :quantity_shorted, null: false

      t.timestamps
    end
  end
end

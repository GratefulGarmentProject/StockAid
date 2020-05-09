class CreateCountSheets < ActiveRecord::Migration[5.0][5.0]
  def change
    create_table :count_sheets do |t|
      t.references :inventory_reconciliation, null: false, foreign_key: true, index: true
      t.references :bin, foreign_key: true, index: true
      t.text :counter_names, null: false, array: true, default: []
      t.boolean :complete, null: false, default: false
      t.timestamps null: false
      t.index [:bin_id, :inventory_reconciliation_id], unique: true
    end

    create_table :count_sheet_details do |t|
      t.references :count_sheet, null: false, foreign_key: true, index: true
      t.references :item, null: false, foreign_key: true, index: true
      t.integer :counts, null: false, array: true, defaut: []
      t.integer :final_count
      t.index [:count_sheet_id, :item_id], unique: true
      t.timestamps null: false
    end
  end
end

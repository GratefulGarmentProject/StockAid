class CreateInventoryReconciliations < ActiveRecord::Migration
  def change
    create_table :inventory_reconciliations do |t|
      t.string :title
      t.references :user, null: false, foreign_key: true
      t.boolean :complete, null: false, default: false
      t.timestamps null: false
    end

    create_table :reconciliation_unchanged_items do |t|
      t.references :inventory_reconciliation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.timestamps null: false
      t.index :inventory_reconciliation_id, name: "rui_on_ir_id"
    end

    create_table :reconciliation_notes do |t|
      t.references :inventory_reconciliation, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps null: false
    end
  end
end

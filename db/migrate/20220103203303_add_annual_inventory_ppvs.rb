class AddAnnualInventoryPpvs < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_inventory_ppvs do |t|
      t.integer :year
      t.decimal :total_inventory_value, precision: 13, scale: 2
      t.decimal :annual_ppv, precision: 13, scale: 2
      t.decimal :real_inventory_value, precision: 13, scale: 2

      t.timestamps null: false
    end

    add_index :annual_inventory_ppvs, :year
  end
end

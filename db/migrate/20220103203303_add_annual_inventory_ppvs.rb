class AddAnnualInventoryPpvs < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_inventory_ppvs do |t|
      t.integer :year
      t.decimal :total_inventory_value
      t.decimal :annual_ppv
      t.decimal :real_inventory_value

      t.timestamps null: false
    end

    add_index :annual_inventory_ppvs, :year
  end
end

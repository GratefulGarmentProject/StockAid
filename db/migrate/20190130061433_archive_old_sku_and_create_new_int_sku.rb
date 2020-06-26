class ArchiveOldSkuAndCreateNewIntSku < ActiveRecord::Migration[5.0][5.0]
  def change
    rename_column :items, :sku, :old_sku

    add_column :categories, :next_sku, :integer, default: 1, null: false

    add_column :items, :sku, :integer

    Item.unscoped.includes(:category).each do |item|
      item.sku = item.generate_sku
      item.save!
    end

    change_column_null :items, :sku, false

    add_index :items, :sku, unique: true
  end
end

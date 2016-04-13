class AddSkuAndPriceToItem < ActiveRecord::Migration
  def change
    add_column :items, :sku, :string
    add_column :items, :price, :numeric
  end
end

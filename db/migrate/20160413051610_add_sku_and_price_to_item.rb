class AddSkuAndPriceToItem < ActiveRecord::Migration
  def change
    add_column :items, :sku, :string
    add_column :items, :price, :decimal, :precision => 8, :scale => 2
  end
end

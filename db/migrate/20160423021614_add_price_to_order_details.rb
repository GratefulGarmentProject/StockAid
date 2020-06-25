class AddPriceToOrderDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :order_details, :price, :decimal, :precision => 8, :scale => 2
  end
end

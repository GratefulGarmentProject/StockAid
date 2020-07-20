class ChangePriceToValue < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :price, :value
    rename_column :order_details, :price, :value
  end
end

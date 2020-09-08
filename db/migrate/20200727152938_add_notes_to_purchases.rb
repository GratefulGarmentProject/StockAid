class AddNotesToPurchases < ActiveRecord::Migration[5.1]
  def change
    add_column :purchases, :notes, :string
  end
end

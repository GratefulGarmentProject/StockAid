class AddNotesToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :notes, :string
  end
end

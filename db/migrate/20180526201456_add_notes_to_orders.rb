class AddNotesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :notes, :string
  end
end

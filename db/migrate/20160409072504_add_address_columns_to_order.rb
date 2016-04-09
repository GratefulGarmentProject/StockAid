class AddAddressColumnsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :ship_to_address, :string
  end
end

class AddAddressToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :address, :string, null: false, default: "123 Fake Street, Campbell, CA 95008"
    change_column_default :users, :address, nil
  end
end

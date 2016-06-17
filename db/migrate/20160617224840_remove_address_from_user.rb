class RemoveAddressFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :address, :string, null: false, default: nil
  end
end

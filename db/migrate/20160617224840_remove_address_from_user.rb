class RemoveAddressFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :address, :string, null: false, default: nil
  end
end

class UpdateUserPhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :phone_number, :primary_number
    add_column :users, :secondary_number, :string
  end
end

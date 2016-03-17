class UpdateUserPhoneNumbers < ActiveRecord::Migration
  def change
    rename_column :users, :phone_number, :primary_number
    add_column :users, :secondary_number, :string
  end
end

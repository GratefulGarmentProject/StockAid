class AddSecondaryNumberToDonors < ActiveRecord::Migration[5.0]
  def change
    rename_column :donors, :phone_number, :primary_number
    add_column :donors, :secondary_number, :string
  end
end

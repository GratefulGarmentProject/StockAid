class AddSecondaryNumberToDonors < ActiveRecord::Migration[5.0]
  def change
    add_column :donors, :primary_number, :string
    rename_column :donors, :phone_number, :secondary_number
  end
end

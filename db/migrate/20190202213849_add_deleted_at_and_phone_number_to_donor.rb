class AddDeletedAtAndPhoneNumberToDonor < ActiveRecord::Migration[5.0][5.0]
  def change
    add_column :donors, :deleted_at, :datetime
    add_column :donors, :phone_number, :string
  end
end

class AddPhoneNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string, null: false, default: "000-000-0000"
    change_column_default :users, :phone_number, nil
  end
end

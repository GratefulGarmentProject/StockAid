class AddNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :string, null: false, default: "Anonymous"
    change_column_default :users, :name, nil
  end
end

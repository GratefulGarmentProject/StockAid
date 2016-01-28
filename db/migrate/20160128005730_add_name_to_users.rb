class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, null: false, default: "Anonymous"
    change_column_default :users, :name, nil
  end
end

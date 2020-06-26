class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone_number
      t.string :email_address
      t.timestamps null: false
      t.index :name
    end
  end
end

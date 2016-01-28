class CreateOrganizationUsers < ActiveRecord::Migration
  def change
    create_table :organization_users do |t|
      t.references :organization, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.string :role, null: false, default: "none"
      t.timestamps null: false
      t.index [:organization_id, :user_id], unique: true
    end
  end
end

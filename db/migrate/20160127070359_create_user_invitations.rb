class CreateUserInvitations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_invitations do |t|
      t.references :organization, foreign_key: true, null: false
      t.string :email, null: false
      t.string :auth_token, null: false
      t.datetime :expires_at, null: false
      t.timestamps null: false
      t.index :auth_token, unique: true
    end
  end
end

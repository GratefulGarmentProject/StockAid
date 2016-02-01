class AddMoreDetailsToUserInvitations < ActiveRecord::Migration
  def change
    change_table :user_invitations do |t|
      t.integer :invited_by_id, null: false
      t.string :name, null: false
      t.string :role, null: false, default: "none"
    end

    add_foreign_key :user_invitations, :users, column: :invited_by_id
  end
end

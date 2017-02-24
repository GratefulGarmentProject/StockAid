class AddUsedColumnToUserInvitations < ActiveRecord::Migration
  def change
    add_column :user_invitations, :used, :boolean, default: false
  end
end

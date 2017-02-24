class AddUsedColumnToUserInvitations < ActiveRecord::Migration
  def change
    add_column :user_invitations, :used, :boolean, default: false

    update_existing_user_invitations
  end

  def update_existing_user_invitations
    UserInvitation.all.each do |ui|
      user = User.where(email: ui.email)
      user_already_at_org = false
      user_already_at_org = OrganizationUser.where(id: user.id, organization: ui.organization_id) if user.present?
      ui.update!(used: true) if user_already_at_org.present?
    end
  end
end

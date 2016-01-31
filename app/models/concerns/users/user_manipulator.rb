module Users
  module UserManipulator
    extend ActiveSupport::Concern

    def can_invite_user?
      super_admin? || admin?
    end

    def can_invite_user_at?(organization)
      super_admin? || admin_at?(organization)
    end

    def organizations_with_with_invite_user_access
      organizations_with_admin_access
    end

    def invite_user(params)
      transaction do
        user_params = params.require(:user)
        organization = Organization.find(user_params[:organization_id])
        raise PermissionError unless can_invite_user_at?(organization)
        create_params = user_params.permit(:name, :email, :role)
        create_params[:organization] = organization
        UserInvitation.create_or_add_to_organization(self, create_params)
      end
    end
  end
end

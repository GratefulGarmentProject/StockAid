module Users
  module UserManipulator
    extend ActiveSupport::Concern

    def can_invite_user?
      super_admin? || admin?
    end

    def can_invite_user_at?(organization)
      super_admin? || admin_at?(organization)
    end

    def can_update_user?(user = nil)
      if !user
        # Checking if this user has general access to update other users
        super_admin? || admin?
      elsif user == self
        # Users can always update themselves
        true
      else
        # Updating a specific user requires update user permission at that organization
        super_admin? || user.organizations.any? { |organization| can_update_user_at?(organization) }
      end
    end

    def can_update_user_at?(organization)
      super_admin? || admin_at?(organization)
    end

    def invite_user(params)
      invitation = transaction do
        user_params = params.require(:user)
        organization = Organization.find(user_params[:organization_id])
        raise PermissionError unless can_invite_user_at?(organization)
        create_params = user_params.permit(:name, :email, :role)
        create_params[:organization] = organization
        UserInvitation.create_or_add_to_organization(self, create_params)
      end

      invitation.invite_mailer(self).deliver_now
    end

    module ClassMethods
      def updateable_by(user)
        if user.super_admin?
          all
        else
          at_organization(user.organizations_with_permission_enabled(:can_update_user_at?))
        end
      end
    end
  end
end

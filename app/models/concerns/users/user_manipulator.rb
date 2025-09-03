module Users
  module UserManipulator
    extend ActiveSupport::Concern
    attr_reader :original_email

    def can_subscribe_to_notifications?(_type = nil)
      # nil type means general notification subscription check, explicit type
      # asks if can subscribe to that type. Right now, they are the same thing.
      root_admin?
    end

    def super_edit_user_access?(user)
      super_admin? && role_object >= user.role_object
    end

    def can_invite_user?
      super_admin? || admin?
    end

    def can_invite_user_at?(organization)
      super_admin? || admin_at?(organization)
    end

    def can_delete_user?(user = nil)
      if !user
        # Checking if this user has general access to delete other users
        super_admin?
      else
        # Deleting a specific other user
        super_edit_user_access?(user)
      end
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
        super_edit_user_access?(user) || user.organizations.any? { |organization| can_update_user_at?(organization) }
      end
    end

    def can_force_password_reset?(user = nil)
      if !user
        # Checking if this user has general access to force password resets
        super_admin? || admin?
      else
        super_edit_user_access?(user) || user.organizations.any? { |organization| can_force_password_reset_at?(organization) }
      end
    end

    def can_update_user_details?(user)
      super_edit_user_access?(user) || user == self
    end

    def can_update_user_role?(user)
      super_edit_user_access?(user) || user.organizations.any? { |organization| can_update_user_role_at?(organization) }
    end

    def can_update_password?(user)
      super_edit_user_access?(user) || user == self
    end

    def can_update_user_at?(organization)
      super_admin? || admin_at?(organization)
    end

    def can_update_user_role_at?(organization)
      can_update_user_at?(organization)
    end

    def can_force_password_reset_at?(organization)
      can_update_user_at?(organization)
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

    def update_user(params) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      user = transaction do
        user = User.find(params[:id])
        raise PermissionError unless can_update_user?(user)

        if can_update_user_details?(user) && params[:user].present?
          user_permitted_params = permitted_params(params)
          raise PermissionError if user_permitted_params[:role] == "root" && !root_admin?
          user.update_details(user_permitted_params)
        end

        if can_subscribe_to_notifications? && user == self
          user.update_subscriptions(params.require(:subscriptions).permit(Notification::SUBSCRIPTION_TYPES.keys))
        end

        user.update_roles(self, params) if can_update_user_role?(user)
        user.update_password(self, params) if can_update_password?(user)
        user
      end

      user.deliver_change_emails
    end

    def permitted_params(params)
      if super_admin?
        params.require(:user).permit(:name, :email, :primary_number, :secondary_number, :role)
      else
        params.require(:user).permit(:name, :email, :primary_number, :secondary_number)
      end
    end

    def destroy_user(params)
      raise PermissionError unless can_delete_user?

      transaction do
        user_to_delete = User.find(params[:id])
        raise PermissionError unless can_delete_user?(user_to_delete)
        user_to_delete.organization_users.each(&:destroy!)
      end
    end

    def reset_password_for_user(params)
      user = User.find(params[:id])
      raise PermissionError unless can_force_password_reset?(user)
      UserMailer.request_password_reset(self, user).deliver_now
      user
    end

    class_methods do
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

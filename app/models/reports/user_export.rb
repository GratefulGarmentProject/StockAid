module Reports
  class UserExport
    include CsvExport

    FIELDS = %w[id name email cell_phone organization role last_login].freeze

    def initialize(current_user, _session)
      @current_user = current_user
      @users = User.includes(:organizations).order(:name).updateable_by(current_user).not_deleted
    end

    def each
      @users.each do |user|
        user_organizations = @current_user.filter_organizations_with_permission_enabled(user.organizations,
                                                                                        :can_update_user_at?).to_a

        if user_organizations.empty?
          if user.super_admin?
            yield Row.new(user, "All Organizations", I18n.t(user.role, scope: "role.user"))
          else
            yield Row.new(user, "No Organizations", "N/A")
          end
        else
          user_organizations.each do |organization|
            yield Row.new(user, organization.name, I18n.t(user.role_at(organization), scope: "role.organization"))
          end
        end
      end
    end

    class Row
      attr_reader :user, :cell_phone, :organization, :role, :last_login

      delegate :id, :name, :email, to: :user

      def initialize(user, organization, role)
        @user = user
        @organization = organization
        @role = role
        @cell_phone = user.primary_number
        @last_login = user.current_sign_in_at&.strftime("%m/%d/%Y")
      end
    end
  end
end

module Users
  module IntegrationManipulator
    extend ActiveSupport::Concern

    def can_view_integrations?
      super_admin?
    end
  end
end

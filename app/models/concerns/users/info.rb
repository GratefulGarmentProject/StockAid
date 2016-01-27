module Users
  module Info
    extend ActiveSupport::Concern

    def super_admin?
    end

    def admin?(organization)
    end
  end
end

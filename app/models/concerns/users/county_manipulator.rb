module Users
  module CountyManipulator
    extend ActiveSupport::Concern

    def can_access_counties?
      super_admin?
    end
  end
end

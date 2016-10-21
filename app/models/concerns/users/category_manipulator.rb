module Users
  module CategoryManipulator
    extend ActiveSupport::Concern

    def can_view_or_edit_categories?
      super_admin?
    end
  end
end

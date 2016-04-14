module Users
  module ItemManipulator
    extend ActiveSupport::Concern

    def can_view_or_edit_items?
      super_admin?
    end
  end
end

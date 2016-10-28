module Users
  module ItemManipulator
    extend ActiveSupport::Concern

    def can_view_and_edit_items?
      super_admin?
    end

    def can_view_items?
      true
    end
  end
end

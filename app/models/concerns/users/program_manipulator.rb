module Users
  module ProgramManipulator
    extend ActiveSupport::Concern

    def can_view_programs?
      super_admin?
    end

    def can_edit_programs?
      super_admin?
    end
  end
end

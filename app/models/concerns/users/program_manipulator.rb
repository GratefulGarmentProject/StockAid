module Users
  module ProgramManipulator
    extend ActiveSupport::Concern

    def can_view_programs?
      super_admin?
    end

    def can_create_programs?
      super_admin?
    end

    def can_update_programs?
      can_create_programs?
    end

    def can_delete_programs?
      can_create_programs?
    end
  end
end

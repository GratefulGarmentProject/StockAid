module Users
  module SurveyManipulator
    extend ActiveSupport::Concern

    def can_view_and_edit_surveys?
      super_admin?
    end

    def can_create_surveys?
      super_admin?
    end

    def can_delete_surveys?
      super_admin?
    end
  end
end

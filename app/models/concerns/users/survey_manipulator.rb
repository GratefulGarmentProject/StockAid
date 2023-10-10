module Users
  module SurveyManipulator
    extend ActiveSupport::Concern

    def can_view_and_edit_surveys?
      super_admin?
    end

    def can_email_survey_requests?
      super_admin?
    end

    def can_create_surveys?
      super_admin?
    end

    def can_delete_surveys?
      super_admin?
    end

    def can_view_survey_answers?(_order)
      super_admin?
    end

    def can_answer_organization_survey?(survey_organization_request)
      super_admin? || member_at?(survey_organization_request.organization)
    end
  end
end

class SurveyOrganizationRequest < ApplicationRecord
  belongs_to :survey_request
  belongs_to :organization
end

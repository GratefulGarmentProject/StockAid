class SurveyOrganizationRequest < ApplicationRecord
  belongs_to :survey_request
  belongs_to :organization

  def status
    if answered
      "Responded"
    elsif skipped
      "Skipped"
    else
      "Waiting"
    end
  end

  def status_class
    if answered
      nil
    elsif skipped
      "warning"
    else
      "danger"
    end
  end
end

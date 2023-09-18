class SurveyOrganizationRequest < ApplicationRecord
  belongs_to :survey_request
  belongs_to :organization

  def mark_skipped
    transaction do
      self.skipped = true
      self.save!
      survey_request.update_organization_counts
    end
  end

  def unanswered?
    !answered && !skipped
  end

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

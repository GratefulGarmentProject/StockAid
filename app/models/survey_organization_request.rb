class SurveyOrganizationRequest < ApplicationRecord
  belongs_to :survey_request
  belongs_to :organization
  has_one :survey_answer

  def self.unanswered
    where(answered: false, skipped: false)
  end

  def self.for_organizations(organizations)
    where(organization: organizations)
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

class SurveyRequest < ApplicationRecord
  belongs_to :survey
  belongs_to :survey_revision
  has_many :survey_organization_requests

  def unanswered_requests
    survey_organization_requests.select(&:unanswered?)
  end

  def closed?
    closed_at.present?
  end

  def complete?
    organizations_waiting <= 0
  end

  def status_class
    return "danger" unless complete?
  end

  def organizations_waiting
    organizations_requested - organizations_responded - organizations_skipped
  end

  def update_organization_counts
    self.organizations_requested = survey_organization_requests.count
    self.organizations_responded = survey_organization_requests.where(answered: true).count
    self.organizations_skipped = survey_organization_requests.where(skipped: true).count
    save!
  end
end

class SurveyRequest < ApplicationRecord
  belongs_to :survey
  belongs_to :survey_revision
  has_many :survey_organization_requests

  def update_organization_counts
    self.organizations_requested = survey_organization_requests.count
    self.organizations_responded = survey_organization_requests.where(answered: true).count
    self.organizations_skipped = survey_organization_requests.where(skipped: true).count
    save!
  end
end

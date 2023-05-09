class SurveyRevision < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers

  def deletable?
    !has_answers? && (!active? || survey.survey_revisions.count == 1)
  end

  def has_answers? # rubocop:disable Naming/PredicateName
    survey_answers.present?
  end
end

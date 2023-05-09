class SurveyRevision < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers

  def deletable?
    return false if survey_answers.count > 0
    return true unless active?

    survey.deletable?
  end
end

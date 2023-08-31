class SurveyRevision < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers
  has_many :survey_requests

  def deletable?
    return false if survey_answers.count > 0
    return false if survey_requests.count > 0
    return true unless active?

    survey.deletable?
  end

  def to_definition
    SurveyDef::Definition.new(definition)
  end

  def blank_answers
    to_definition.blank_answers
  end
end

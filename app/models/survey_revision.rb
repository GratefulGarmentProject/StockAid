class SurveyRevision < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers

  def has_answers? # rubocop:disable Naming/PredicateName
    survey_answers.present?
  end
end

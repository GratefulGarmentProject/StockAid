class SurveyAnswer < ApplicationRecord
  belongs_to :survey_revision
  belongs_to :order, optional: true
  belongs_to :survey_organization_request, optional: true
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :last_updated_by, class_name: "User", optional: true

  def self.update_answer(where:, user:, revision:, survey_params:)
    answers = revision.to_definition.answers_from_params(survey_params[:answers])
    existing_answer = self.where(where).first

    if existing_answer
      existing_answer.last_updated_by = user
      existing_answer.survey_revision = revision
      existing_answer.answer_data = answers.serialize
      existng_answer.save!
    else
      SurveyAnswer.create!(where) do |answer|
        answer.creator = user
        answer.survey_revision = revision
        answer.answer_data = answers.serialize
      end
    end
  end

  def answers
    survey_revision.to_definition.deserialize_answers(answer_data)
  end
end

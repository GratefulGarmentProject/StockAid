module SurveysHelper
  def survey_answer_value(answer)
    if answer.value.present?
      answer.display_value
    else
      tag.em "No answer provided", class: "text-danger"
    end
  end
end

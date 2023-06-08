class AddLastUpdatedByToSurveyAnswers < ActiveRecord::Migration[5.2]
  def change
    add_reference :survey_answers, :last_updated_by, null: true, index: false, foreign_key: { to_table: :users }
  end
end

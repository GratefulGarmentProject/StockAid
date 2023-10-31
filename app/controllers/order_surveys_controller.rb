class OrderSurveysController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?

  def index
    @surveys = Survey.where(id: ProgramSurvey.distinct(:survey_id).pluck(:survey_id)).order(:title)
  end

  def orders
    @survey = Survey.find(params[:id])
    @survey_answers = SurveyAnswer.includes(order: [:organization]).where.not(order_id: nil).where(survey_revision: @survey.survey_revisions).order(order_id: :desc)
  end
end

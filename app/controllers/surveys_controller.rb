class SurveysController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  active_tab "surveys"

  def index
    @surveys = Survey.order(:title)
  end

  def new
    @survey = Survey.new(title: "New Survey")
    @revision = SurveyRevision.new(survey: @survey, title: "Initial Revision")
  end

  def create
    definition = SurveyDef::Definition.from_params(params)

    survey = Survey.create! do |survey|
      survey.title = params[:survey_title]
    end

    survey.survey_revisions.create! do |revision|
      revision.title = params[:revision_title]
      revision.active = params[:active] == "true"
      revision.definition = definition.serialize
    end

    redirect_to action: :index, flash: { success: "Survey created!" }
  end

  def show
    @survey = Survey.find(params[:id])

    @revision =
      if params[:revision_id].present?
        @survey.survey_revisions.find(params[:revision_id])
      else
        @survey.active_or_first_revision
      end
  end

  def update
    raise "TODO"
  end

  def destroy
    raise "TODO"
  end
end

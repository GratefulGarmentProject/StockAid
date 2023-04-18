class SurveysController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  active_tab "surveys"

  def index
    @surveys = Survey.order(:title)
  end

  def new
    @survey = Survey.new(title: "New Survey")
  end

  def create
    definition = SurveyDef::Definition.from_params(params)

    survey = Survey.create! do |survey|
      survey.title = params[:title]
    end

    survey.survey_revisions.create! do |revision|
      revision.title = params[:title]
      revision.active = params[:active] == "true"
      revision.definition = definition.serialize
    end

    redirect_to action: :index, flash: { success: "Survey created!" }
  end

  def show
  end

  def update
    raise "TODO"
  end

  def destroy
    raise "TODO"
  end
end

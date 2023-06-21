class SurveysController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  require_permission :can_create_surveys?, only: %i[create update]
  require_permission :can_delete_surveys?, only: %i[destroy]
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

    survey = Survey.create! do |s|
      s.title = params[:survey_title]
    end

    survey.survey_revisions.create! do |revision|
      revision.title = params[:revision_title]
      revision.active = params[:active] == "true"
      revision.definition = definition.serialize
    end

    redirect_to surveys_path, flash: { success: "Survey created!" }
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

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    flash = {}
    revision_id = params[:revision_id]

    begin
      Survey.transaction do
        survey = Survey.find(params[:id])
        survey.title = params[:survey_title]
        survey.save!

        if params[:activate].present?
          survey.activate_revision!(params)
          flash[:success] = "Revision successfully activated!"
        elsif params[:update].present?
          survey.update_revision!(params)
          flash[:success] = "Revision successfully updated!"
        elsif params[:save_new_revision].present?
          revision_id = survey.save_new_revision!(params).id
          flash[:success] = "New revision successfully created!"
        else
          flash[:error] = "Unknown action!"
          raise ActiveRecord::Rollback
        end
      end
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = "Duplicate name detected, action failed!"
    end

    redirect_to survey_path(params[:id], revision_id: revision_id), flash: flash
  end

  def destroy
    Survey.transaction do
      survey = Survey.find(params[:id])
      revision = survey.survey_revisions.find(params[:revision_id])
      raise "Revision is not deletable!" unless revision.deletable?

      message = "Revision successfully deleted!"
      revision.destroy!

      if survey.survey_revisions.count == 0
        message = "Survey successfully deleted!"
        survey.destroy!
      end

      redirect_to surveys_path, flash: { success: message }
    end
  end

  def demo
    @survey = Survey.find(params[:id])
    @revision =
      if params[:revision_id].present?
        @survey.survey_revisions.find(params[:revision_id])
      else
        @survey.active_or_first_revision
      end
  end

  def submit_demo
    @survey = Survey.find(params[:id])
    survey_params = params[:survey_answers][params[:id]]
    @revision = @survey.survey_revisions.find(survey_params[:revision])
    @answers = @revision.to_definition.answers_from_params(survey_params[:answers])
  end
end

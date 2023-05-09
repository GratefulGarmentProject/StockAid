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

  def update
    flash = {}
    revision_id = params[:revision_id]

    begin
      Survey.transaction do
        survey = Survey.find(params[:id])
        revision = survey.survey_revisions.find(params[:revision_id])
        survey.title = params[:survey_title]
        survey.save!

        if params[:activate].present?
          survey.survey_revisions.update_all(active: false)
          revision.title = params[:revision_title]
          revision.active = true
          revision.save!
          flash[:success] = "Revision successfully activated!"
        elsif params[:update].present?
          revision.title = params[:revision_title]
          revision.save!
          flash[:success] = "Revision successfully updated!"
        elsif params[:save_new_revision].present?
          definition = SurveyDef::Definition.from_params(params)

          new_revision = survey.survey_revisions.create! do |revision|
            revision.title = params[:revision_title]
            revision.active = params[:active] == "true"
            revision.definition = definition.serialize
          end

          revision_id = new_revision.id
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
    survey = Survey.find(params[:id])
    revision = survey.survey_revisions.find(params[:revision_id])
    raise "Cannot destroy an active revision!" if revision.active?
    raise "Cannot destroy a revision that has answers!" if revision.has_answers?
    message = "Revision successfully deleted!"
    revision.destroy!

    if survey.survey_revisions.count == 0
      message = "Survey successfully deleted!"
      survey.destroy!
    end

    redirect_to surveys_path, flash: { success: message }
  end
end

class SurveyRequestsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  require_permission :can_create_surveys?, only: %i[new create]
  active_tab "surveys"

  def index
    @survey_requests = SurveyRequest.includes(:survey).order(created_at: :desc).all.to_a
  end

  def new
    @survey_request = SurveyRequest.new(title: "New Survey Request")
    @organizations = Organization.order(:name).all.to_a
  end

  def show
    Organization.unscoped do
      @survey_request = SurveyRequest.includes(survey_organization_requests: :organization).find(params[:id])
    end
  end

  def create
    SurveyRequest.transaction do
      survey = Survey.find(params[:survey_id])

      request = SurveyRequest.create! do |r|
        r.title = params[:survey_request_title]
        r.survey = survey
        r.survey_revision = survey.active_revision
      end

      params[:organization_ids].each do |org_id|
        org = Organization.find(org_id)
        request.survey_organization_requests.create! organization: org
      end

      request.update_organization_counts
    end

    redirect_to survey_requests_path, flash: { success: "Survey request created!" }
  end
end

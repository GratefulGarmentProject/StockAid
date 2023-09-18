class SurveyRequestsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?, except: %i[answer submit_answer]
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

  def skip
    survey_request = SurveyRequest.find(params[:id])

    survey_request.transaction do
      org_request = survey_request.survey_organization_requests.find(params[:org_request_id])

      unless org_request.unanswered?
        return redirect_to survey_request_path(survey_request), flash: { error: "Organization already submitted an answer, cannot be skipped" }
      end

      org_request.mark_skipped
    end

    redirect_to survey_request_path(survey_request), flash: { warning: "Marked organization as skipped" }
  end

  def answer
    @survey_request = SurveyRequest.find(params[:id])
    @org_request = @survey_request.survey_organization_requests.find(params[:org_request_id])
    raise PermissionError unless current_user.can_answer_organization_survey?(@org_request)
    @survey = @survey_request.survey
    @revision = @survey_request.survey_revision
  end

  def submit_answer
    survey_request = SurveyRequest.find(params[:id])
    org_request = survey_request.survey_organization_requests.find(params[:org_request_id])
    raise PermissionError unless current_user.can_answer_organization_survey?(org_request)
    raise "TODO: #{params.inspect}"
    redirect_to Redirect.to(orders_path, params, allow: ["orders", "survey_request"])
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

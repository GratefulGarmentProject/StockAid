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
        return redirect_to survey_request_path(survey_request), flash: {
          error: "Organization already submitted an answer, cannot be skipped"
        }
      end

      org_request.skipped = true
      org_request.save!
      survey_request.update_organization_counts
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

  def submit_answer # rubocop:disable Metrics/AbcSize
    survey_request = SurveyRequest.find(params[:id])

    survey_request.transaction do
      revision = survey_request.survey_revision
      org_request = survey_request.survey_organization_requests.find(params[:org_request_id])
      survey_params = params[:survey_answers][survey_request.survey.id.to_s]
      raise PermissionError if survey_request.closed?
      raise PermissionError unless current_user.can_answer_organization_survey?(org_request)
      raise "Revision mismatch!" if revision.id.to_s != survey_params[:revision]

      SurveyAnswer.update_answer(
        where: { survey_organization_request: org_request },
        user: current_user,
        revision: revision,
        survey_params: survey_params
      )

      org_request.skipped = false
      org_request.answered = true
      org_request.save!
      survey_request.update_organization_counts
    end

    redirect_to Redirect.to(orders_path, params, allow: %i[orders survey_request])
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

require "set"

class SurveyRequestsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  require_permission :can_create_surveys?, only: %i[new create]
  require_permission :can_email_survey_requests?, only: %i[email submit_email]
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

  def report
    Organization.unscoped do
      @survey_request = SurveyRequest.includes(survey_organization_requests: %i[organization survey_answer])
                                     .find(params[:id])
      @data = Reports::SurveyRequestData.new(@survey_request)
    end
  end

  def export
    Organization.unscoped do
      @survey_request = SurveyRequest.includes(survey_organization_requests: %i[organization survey_answer])
                                     .find(params[:id])
      @data = Reports::SurveyRequestData.new(@survey_request)
    end

    send_csv @data, filename: "survey-request-#{@survey_request.id}-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
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

  def email
    Organization.unscoped do
      @survey_request = SurveyRequest.includes(survey_organization_requests: :organization).find(params[:id])

      @preselected_org_request =
        if params[:org_request_id].present?
          @survey_request.unanswered_requests.find { |org_request| org_request.id == params[:org_request_id].to_i }
        end
    end
  end

  def submit_email # rubocop:disable Metrics/AbcSize
    survey_request = SurveyRequest.includes(survey_organization_requests: :organization).find(params[:id])
    notified_org_requests = []
    raise "Must have at least 1 org_request_id selected" if params[:org_request_ids].blank?
    requested_org_request_ids = Set.new(params[:org_request_ids].map(&:to_i))

    survey_request.unanswered_requests.each do |org_request|
      if requested_org_request_ids.include?(org_request.id)
        notified_org_requests << org_request
        SurveyRequestMailer.notify_organization(survey_request, org_request, params).deliver_now
      end
    end

    SurveyRequestMailer.notify_receipt(current_user, survey_request, notified_org_requests, params).deliver_now

    redirect_to survey_request_path(survey_request), flash: {
      success: "Survey request notification sent to #{notified_org_requests.size} organizations!"
    }
  end
end

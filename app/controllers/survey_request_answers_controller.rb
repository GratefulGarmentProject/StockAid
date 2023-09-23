class SurveyRequestAnswersController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?, except: %i[show update]
  active_tab "surveys"

  def show
    @survey_request = SurveyRequest.find(params[:survey_request_id])
    @org_request = @survey_request.survey_organization_requests.find(params[:org_request_id])
    raise PermissionError unless current_user.can_answer_organization_survey?(@org_request)
    @survey = @survey_request.survey
    @revision = @survey_request.survey_revision

    @answers =
      case params[:action]
      when "show"
        @org_request.survey_answer&.answer_data || @revision.blank_answers
      when "view"
        @org_request.survey_answer.answers
      else
        raise "Unexpected action: #{params[:action]}"
      end
  end

  alias view show

  def update # rubocop:disable Metrics/AbcSize
    survey_request = SurveyRequest.find(params[:survey_request_id])

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

  def skip
    survey_request = SurveyRequest.find(params[:survey_request_id])

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
end

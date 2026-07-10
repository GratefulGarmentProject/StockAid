require "rails_helper"

RSpec.describe SurveyRequestAnswersController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:survey_request) { survey_requests(:basic_survey_request) }
  let!(:unanswered_org_request) { survey_organization_requests(:foo_unanswered_org_request) }
  let!(:skipped_org_request) { survey_organization_requests(:no_order_skipped_org_request) }

  before { sign_in super_admin }

  describe "#show" do
    it "renders the survey answer form" do
      get survey_request_answer_path(survey_request, unanswered_org_request)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    let(:survey) { survey_request.survey }
    let(:revision) { survey_request.survey_revision }

    it "saves the answer and redirects" do
      patch survey_request_answer_path(survey_request, unanswered_org_request), params: {
        survey_answers: {
          survey.id.to_s => {
            revision: revision.id.to_s,
            answers: { "0" => "My answer to the survey" }
          }
        }
      }
      expect(response).to redirect_to(orders_path)
      expect(unanswered_org_request.reload.answered).to be true
    end
  end

  describe "#skip" do
    it "marks an unanswered org request as skipped and redirects" do
      post skip_survey_request_answer_path(survey_request, unanswered_org_request)
      expect(response).to redirect_to(survey_request_path(survey_request))
      expect(flash[:warning]).to be_present
      expect(unanswered_org_request.reload.skipped).to be true
    end

    it "redirects with an error when the org has already answered" do
      answered_org_request = survey_organization_requests(:acme_answered_org_request)
      post skip_survey_request_answer_path(survey_request, answered_org_request)
      expect(response).to redirect_to(survey_request_path(survey_request))
      expect(flash[:error]).to be_present
    end
  end
end

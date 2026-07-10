require "rails_helper"

RSpec.describe SurveyRequestsController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:survey) { surveys(:active_survey) }
  let!(:survey_request) { survey_requests(:basic_survey_request) }
  let!(:org_request) { survey_organization_requests(:foo_unanswered_org_request) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders the survey requests list" do
      get survey_requests_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders the new survey request form" do
      get new_survey_request_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders the survey request detail page" do
      get survey_request_path(survey_request)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a survey request and redirects" do
      expect do
        post survey_requests_path, params: {
          survey_id: survey.id,
          survey_request_title: "New Spec Survey Request",
          organization_ids: [organizations(:acme).id]
        }
      end.to change(SurveyRequest, :count).by(1)
      expect(response).to redirect_to(survey_requests_path)
      expect(flash[:success]).to be_present
    end
  end

  describe "#email" do
    it "renders the email form for the survey request" do
      get email_survey_request_path(survey_request)
      expect(response).to have_http_status(:ok)
    end

    it "pre-selects an org request when org_request_id is provided" do
      get email_survey_request_path(survey_request), params: { org_request_id: org_request.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#report" do
    it "renders the survey request report page" do
      get report_survey_request_path(survey_request)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#export" do
    it "returns CSV data" do
      get export_survey_request_path(survey_request)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "#submit_email" do
    it "sends emails and redirects with a success flash" do
      expect do
        post email_survey_request_path(survey_request), params: {
          org_request_ids: [org_request.id.to_s],
          email_subject: "Survey for {{organization_name}}",
          email_body: "Please complete the survey, {{organization_name}}."
        }
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(response).to redirect_to(survey_request_path(survey_request))
      expect(flash[:success]).to include("1 organizations")
    end
  end
end

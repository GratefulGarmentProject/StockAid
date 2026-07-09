require "rails_helper"

RSpec.describe SurveysController, type: :request do
  let(:super_admin) { users(:root) }
  let(:survey) { surveys(:active_survey) }
  let(:revision) { survey_revisions(:active_survey_v1) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get surveys_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_survey_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get survey_path(survey)
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with a specific revision_id" do
      get survey_path(survey), params: { revision_id: revision.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a survey and redirects" do
      post surveys_path, params: {
        survey_title: "New Test Survey",
        revision_title: "v1",
        active: "true",
        fields: { "0" => { type: "text", label: "Test Question" } }
      }
      expect(response).to redirect_to(surveys_path)
      expect(flash[:success]).to be_present
      expect(Survey.find_by(title: "New Test Survey")).to be_present
    end
  end

  describe "#update" do
    context "activate" do
      it "activates a revision and redirects" do
        patch survey_path(survey), params: {
          survey_title: survey.title,
          revision_id: revision.id,
          revision_title: revision.title,
          activate: "1",
          fields: {}
        }
        expect(response).to have_http_status(:found)
        expect(flash[:success]).to be_present
      end
    end

    context "update_revision" do
      it "updates a revision and redirects" do
        patch survey_path(survey), params: {
          survey_title: survey.title,
          revision_id: revision.id,
          revision_title: "v1 Updated",
          update: "1",
          fields: {}
        }
        expect(response).to have_http_status(:found)
        expect(flash[:success]).to be_present
      end
    end

    context "save_new_revision" do
      it "creates a new revision and redirects" do
        patch survey_path(survey), params: {
          survey_title: survey.title,
          revision_id: revision.id,
          revision_title: "v2 New",
          save_new_revision: "1",
          fields: { "0" => { type: "text", label: "New Question" } }
        }
        expect(response).to have_http_status(:found)
        expect(flash[:success]).to be_present
        expect(survey.survey_revisions.count).to be >= 2
      end
    end
  end

  describe "#destroy" do
    context "a deletable survey" do
      let!(:deletable_survey) do
        Survey.create!(title: "Deletable Survey").tap do |s|
          s.survey_revisions.create!(title: "v1", active: false, definition: { "fields" => [] })
        end
      end
      let(:deletable_revision) { deletable_survey.survey_revisions.first }

      it "destroys the survey and redirects" do
        delete survey_path(deletable_survey), params: { revision_id: deletable_revision.id }
        expect(response).to redirect_to(surveys_path)
        expect(flash[:success]).to be_present
        expect(Survey.find_by(id: deletable_survey.id)).to be_nil
      end
    end
  end

  describe "#demo" do
    it "renders the survey demo page" do
      get demo_survey_path(survey), params: { revision_id: revision.id }
      expect(response).to have_http_status(:ok)
    end

    it "renders with active revision when no revision_id given" do
      get demo_survey_path(survey)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#submit_demo" do
    it "renders the demo results page" do
      post demo_survey_path(survey), params: {
        survey_answers: {
          survey.id.to_s => {
            revision: revision.id.to_s,
            answers: { "0" => "Test answer" }
          }
        }
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get surveys_path }.to raise_error(PermissionError)
    end
  end
end

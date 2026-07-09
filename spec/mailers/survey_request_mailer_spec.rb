require "rails_helper"

describe SurveyRequestMailer, type: :mailer do
  let(:survey_request) { survey_requests(:basic_survey_request) }
  let(:org_request) { survey_organization_requests(:foo_unanswered_org_request) }
  let(:user) { users(:root) }

  describe ".attempt" do
    it "creates a MailAttempt with the given org_request and success status" do
      attempt = SurveyRequestMailer.attempt(org_request, true)
      expect(attempt).to be_a(SurveyRequestMailer::MailAttempt)
      expect(attempt.org_request).to eq(org_request)
      expect(attempt.success).to be true
    end
  end

  describe "MailAttempt" do
    it "stores org_request and success" do
      attempt = SurveyRequestMailer::MailAttempt.new(org_request, false)
      expect(attempt.org_request).to eq(org_request)
      expect(attempt.success).to be false
    end

    it "has settable attributes" do
      attempt = SurveyRequestMailer::MailAttempt.new(org_request, true)
      attempt.success = false
      expect(attempt.success).to be false
    end
  end

  describe "#notify_organization" do
    let(:params) do
      {
        email_subject: "Survey for {{organization_name}}",
        email_body: "Please fill out the survey, {{organization_name}}."
      }
    end

    it "sends to the organization's email" do
      mail = described_class.notify_organization(survey_request, org_request, params)
      expect(mail.to).to include(org_request.organization.email)
    end

    it "interpolates organization name into the subject" do
      mail = described_class.notify_organization(survey_request, org_request, params)
      expect(mail.subject).to include(org_request.organization.name)
    end
  end

  describe "#notify_receipt" do
    let(:mail_attempts) { [SurveyRequestMailer::MailAttempt.new(org_request, true)] }
    let(:params) do
      {
        email_subject: "Survey Notification",
        email_body: "Survey was sent."
      }
    end

    it "sends to the current user's email" do
      mail = described_class.notify_receipt(user, survey_request, mail_attempts, params)
      expect(mail.to).to include(user.email)
    end

    it "includes the site name in the subject" do
      mail = described_class.notify_receipt(user, survey_request, mail_attempts, params)
      expect(mail.subject).to include("Survey Notification Receipt")
    end
  end
end

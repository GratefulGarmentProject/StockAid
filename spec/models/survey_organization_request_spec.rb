require "rails_helper"

describe SurveyOrganizationRequest, type: :model do
  let(:answered) { survey_organization_requests(:acme_answered_org_request) }
  let(:unanswered) { survey_organization_requests(:foo_unanswered_org_request) }
  let(:skipped) { survey_organization_requests(:no_order_skipped_org_request) }

  describe ".unanswered" do
    it "returns requests that are not answered and not skipped" do
      results = SurveyOrganizationRequest.unanswered
      expect(results).to include(unanswered)
      expect(results).not_to include(answered)
      expect(results).not_to include(skipped)
    end
  end

  describe ".for_organizations" do
    it "returns requests for the given organizations" do
      results = SurveyOrganizationRequest.for_organizations([organizations(:acme)])
      expect(results).to include(answered)
      expect(results).not_to include(unanswered)
    end
  end

  describe "#unanswered?" do
    it "returns true when not answered and not skipped" do
      expect(unanswered.unanswered?).to be true
    end

    it "returns false when answered" do
      expect(answered.unanswered?).to be false
    end

    it "returns false when skipped" do
      expect(skipped.unanswered?).to be false
    end
  end

  describe "#status" do
    it "returns 'Responded' when answered" do
      expect(answered.status).to eq("Responded")
    end

    it "returns 'Skipped' when skipped" do
      expect(skipped.status).to eq("Skipped")
    end

    it "returns 'Waiting' when unanswered" do
      expect(unanswered.status).to eq("Waiting")
    end
  end

  describe "#status_class" do
    it "returns nil when answered" do
      expect(answered.status_class).to be_nil
    end

    it "returns 'warning' when skipped" do
      expect(skipped.status_class).to eq("warning")
    end

    it "returns 'danger' when unanswered" do
      expect(unanswered.status_class).to eq("danger")
    end
  end
end

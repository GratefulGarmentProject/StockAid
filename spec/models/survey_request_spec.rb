require "rails_helper"

describe SurveyRequest, type: :model do
  let(:open_request) { survey_requests(:basic_survey_request) }
  let(:closed_request) { survey_requests(:closed_survey_request) }

  describe "#closed?" do
    it "returns false when not closed" do
      expect(open_request.closed?).to be false
    end

    it "returns true when closed_at is set" do
      expect(closed_request.closed?).to be true
    end
  end

  describe "#complete?" do
    it "returns false when organizations are still waiting" do
      expect(open_request.complete?).to be false
    end

    it "returns true when all organizations responded" do
      expect(closed_request.complete?).to be true
    end
  end

  describe "#status_class" do
    it "returns 'danger' when incomplete" do
      expect(open_request.status_class).to eq("danger")
    end

    it "returns nil when complete" do
      expect(closed_request.status_class).to be_nil
    end
  end

  describe "#organizations_waiting" do
    it "returns the count of organizations not yet responded or skipped" do
      expect(open_request.organizations_waiting).to eq(1)
    end

    it "returns 0 when all have responded" do
      expect(closed_request.organizations_waiting).to eq(0)
    end
  end

  describe "#unanswered_requests" do
    it "returns unanswered survey_organization_requests" do
      unanswered = open_request.unanswered_requests
      expect(unanswered).not_to be_empty
      expect(unanswered.all?(&:unanswered?)).to be true
    end
  end

  describe "#update_organization_counts" do
    it "updates counts from the database" do
      open_request.update_organization_counts
      expect(open_request.organizations_requested).to eq(open_request.survey_organization_requests.count)
    end
  end
end

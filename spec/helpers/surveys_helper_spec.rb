require "rails_helper"

RSpec.describe SurveysHelper, type: :helper do
  describe "#survey_answer_value" do
    it "returns display_value when answer has a value" do
      answer = double(value: "Yes", display_value: "Yes")
      expect(helper.survey_answer_value(answer)).to eq("Yes")
    end

    it "returns 'No answer provided' tag when answer has no value" do
      answer = double(value: nil, display_value: nil)
      result = helper.survey_answer_value(answer)
      expect(result).to include("No answer provided")
    end
  end
end

require "rails_helper"

describe SurveyAnswer, type: :model do
  let(:user) { users(:root) }
  let(:survey) { surveys(:active_survey) }
  let(:revision) { survey_revisions(:active_survey_v1) }

  describe ".update_answer" do
    context "when no existing answer" do
      it "creates a new answer record" do
        expect {
          SurveyAnswer.update_answer(
            where: { survey_revision: revision, creator: user },
            user: user,
            revision: revision,
            survey_params: { answers: { "0" => "Test answer" } }
          )
        }.to change(SurveyAnswer, :count).by(1)
      end
    end

    context "when an existing answer already exists" do
      let!(:existing_answer) do
        SurveyAnswer.create!(
          survey_revision: revision,
          creator: user,
          answer_data: revision.to_definition.blank_answers
        )
      end

      it "updates the existing record instead of creating a new one" do
        expect {
          SurveyAnswer.update_answer(
            where: { survey_revision: revision, creator: user },
            user: user,
            revision: revision,
            survey_params: { answers: { "0" => "Updated answer" } }
          )
        }.not_to change(SurveyAnswer, :count)

        expect(existing_answer.reload.last_updated_by).to eq(user)
      end
    end
  end

  describe "#last_updated_by_someone_else?" do
    let(:other_user) { users(:acme_normal) }

    it "returns false when last_updated_by is nil" do
      answer = SurveyAnswer.new(creator: user, last_updated_by: nil)
      expect(answer.last_updated_by_someone_else?).to eq(false)
    end

    it "returns false when last_updated_by is the same as creator" do
      answer = SurveyAnswer.new(creator: user, last_updated_by: user)
      expect(answer.last_updated_by_someone_else?).to eq(false)
    end

    it "returns true when last_updated_by is different from creator" do
      answer = SurveyAnswer.new(creator: user, last_updated_by: other_user)
      expect(answer.last_updated_by_someone_else?).to eq(true)
    end
  end

  describe "#answers" do
    let(:answer) do
      SurveyAnswer.create!(
        survey_revision: revision,
        creator: user,
        answer_data: revision.to_definition.blank_answers
      )
    end

    it "deserializes answers from answer_data" do
      answers = answer.answers
      expect(answers).to be_a(SurveyDef::Answers)
    end
  end
end

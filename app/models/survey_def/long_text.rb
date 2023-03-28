module SurveyDef
  class LongText < SurveyDef::Base
    self.type = "long_text"

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = String
    end
  end
end

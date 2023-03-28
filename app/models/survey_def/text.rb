module SurveyDef
  class Text < SurveyDef::Base
    self.type = "text"

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = String
    end
  end
end

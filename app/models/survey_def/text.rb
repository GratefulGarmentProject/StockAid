module SurveyDef
  class Text < SurveyDef::Base
    self.type = "text"
    self.type_label = "Short Text"

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = String
    end
  end
end

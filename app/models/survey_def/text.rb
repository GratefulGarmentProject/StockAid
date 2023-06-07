module SurveyDef
  class Text < SurveyDef::Base
    self.type = "text"
    self.type_label = "Short Text"

    def answer_value_from_params(param)
      return nil unless param.is_a?(String)

      param
    end

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = String
    end
  end
end

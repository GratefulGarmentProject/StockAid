module SurveyDef
  class Answers
    attr_reader :values

    def initialize(values = [])
      @values = values
    end

    def serialize
      values.map(&:serialize)
    end
  end
end

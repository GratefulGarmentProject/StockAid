module SurveyDef
  class Select < SurveyDef::Base
    self.type = "select"
    attr_accessor :options

    def initialize(hash = nil)
      super(hash)

      if hash
        @options = hash["options"].dup
      else
        @options = []
      end
    end

    def serialize
      super.tap do |result|
        result["options"] = options
      end
    end

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = ::Integer
    end
  end
end

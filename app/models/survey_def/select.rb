module SurveyDef
  class Select < SurveyDef::Base
    self.type = "select"
    self.type_label = "Dropdown of Options"
    attr_accessor :options

    def initialize(hash = nil, params: false)
      super(hash, params: params)

      if params
        @options = hash[:options].dup
      elsif hash
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

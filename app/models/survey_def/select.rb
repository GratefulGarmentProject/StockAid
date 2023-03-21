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

    def to_h
      super.tap do |result|
        result["options"] = options
      end
    end
  end
end

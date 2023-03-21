module SurveyDef
  class Integer < SurveyDef::Base
    self.type = "integer"
    attr_accessor :min, :max

    def initialize(hash = nil)
      super(hash)

      if hash
        @min = hash["min"]
        @max = hash["max"]
      end
    end

    def to_h
      super.tap do |result|
        result["min"] = min
        result["max"] = max
      end
    end
  end
end

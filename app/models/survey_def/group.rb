module SurveyDef
  class Group < SurveyDef::Base
    self.type = "group"
    attr_accessor :min, :max
    attr_reader :fields

    def initialize(hash = nil)
      super(hash)

      if hash
        raise "Missing group fields!" unless hash["fields"]
        @min = hash["min"]
        @max = hash["max"]

        @fields = hash["fields"].map do |field_hash|
          SurveyDef::Definition.construct_field(field_hash)
        end
      else
        @fields = []
      end
    end

    def to_h
      super.tap do |result|
        result["min"] = min
        result["max"] = max
        result["fields"] = fields.map(&:to_h)
      end
    end
  end
end

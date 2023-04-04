module SurveyDef
  class Group < SurveyDef::Base
    self.type = "group"
    self.type_label = "Group of Fields"
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

    def deserialize_answer_value(groups)
      raise SurveyDef::SerializationError.new("Type mismatched: expected Array, got #{groups.class}") unless groups.is_a?(Array)

      groups.map do |group|
        raise SurveyDef::SerializationError.new("Type mismatched: expected Array, got #{group.class}") unless group.is_a?(Array)
        raise SurveyDef::SerializationError.new("Grouped question count mismatch, expected #{fields.size}, got #{group.size}") if group.size != fields.size
        group.map.with_index { |answer, i| fields[i].deserialize_answer(answer) }
      end
    end

    def serialize
      super.tap do |result|
        result["min"] = min
        result["max"] = max
        result["fields"] = fields.map(&:serialize)
      end
    end

    class Answer < SurveyDef::BaseAnswer
      def serialize
        value.map do |answers|
          answers.map(&:serialize)
        end
      end
    end
  end
end

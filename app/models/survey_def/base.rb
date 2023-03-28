module SurveyDef
  class Base
    attr_accessor :label

    class << self
      attr_accessor :type
    end

    def initialize(hash = nil)
      if hash
        raise "Missing field label!" unless hash["label"]
        @label = hash["label"]
      end
    end

    def type
      self.class.type
    end

    def answer_class
      self.class.const_get(:Answer)
    end

    def deserialize_answer(value)
      answer_class.new(self, deserialize_answer_value(value))
    end

    def deserialize_answer_value(value)
      if answer_class.deserialized_class
        raise SurveyDef::SerializationError.new("Type mismatched: expected #{answer_class.deserialized_class}, got #{value.class}") unless value.is_a?(answer_class.deserialized_class)
      end

      value
    end

    # Serialize for the JSONB DB column
    def serialize
      {
        "type" => type,
        "label" => label
      }
    end
  end
end

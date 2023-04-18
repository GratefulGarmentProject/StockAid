module SurveyDef
  class Base
    attr_accessor :label

    class << self
      attr_accessor :type, :type_label

      def to_h
        {
          type: type,
          type_label: type_label
        }
      end
    end

    def initialize(hash = nil)
      if hash
        raise "Missing field label!" unless hash["label"]
        @label = hash["label"]
        @required = hash.fetch("required", false)
      end
    end

    def type
      self.class.type
    end

    def required?
      @required
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

      raise SurveyDef::SerializationError.new("Answer required for: #{label}") if required? && value.blank?
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

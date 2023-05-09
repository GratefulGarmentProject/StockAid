module SurveyDef
  class Base
    attr_accessor :label
    attr_writer :required

    class << self
      attr_accessor :type, :type_label

      def to_h
        {
          type: type,
          type_label: type_label
        }
      end
    end

    def self.from_param(param)
      new(param, params: true)
    end

    def initialize(hash = nil, params: false)
      if params
        raise "Missing field label!" unless hash[:label]
        @label = hash[:label]
        @required = hash[:required] == "true"
      elsif hash
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
      if answer_class.deserialized_class && !value.is_a?(answer_class.deserialized_class)
        raise SurveyDef::SerializationError, "Type mismatched: expected #{answer_class.deserialized_class}, got #{value.class}" # rubocop:disable Layout/LineLength
      end

      raise SurveyDef::SerializationError, "Answer required for: #{label}" if required? && value.blank?
      value
    end

    # Serialize for the JSONB DB column
    def serialize
      {
        "type" => type,
        "label" => label
      }.tap do |result|
        result["required"] = true if required?
      end
    end
  end
end

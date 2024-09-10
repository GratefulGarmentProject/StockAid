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

    def blank_answer
      nil
    end

    def answer_from_params(param)
      value = answer_value_from_params(param)
      raise SurveyDef::SerializationError, "Answer required for: #{label}" if required? && value.blank?
      answer_class.new(self, value)
    end

    def answer_value_from_params(_param)
      raise "#{self.class} does not implement answer_value_from_params!"
    end

    def deserialize_answer(value)
      answer_class.new(self, deserialize_answer_value(value))
    end

    def deserialize_answer_value(value)
      if answer_class.deserialized_class && !value.is_a?(answer_class.deserialized_class) && !value.nil?
        raise SurveyDef::SerializationError, "Type mismatched: expected #{answer_class.deserialized_class}, got #{value.class}"
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

    # Serialize for answer pages
    def to_answers_h
      serialize.tap do |result|
        result["blank"] = blank_answer
      end
    end
  end
end

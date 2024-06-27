module SurveyDef
  class Group < SurveyDef::Base
    self.type = "group"
    self.type_label = "Group of Fields"
    attr_accessor :min, :max
    attr_reader :fields

    def initialize(hash = nil, params: false)
      super(hash, params: params)

      if params
        initialize_from_params(hash)
      elsif hash
        initialize_from_hash(hash)
      else
        @fields = []
      end
    end

    def blank_answer
      [].tap do |result|
        min&.times do
          result << fields.map(&:blank_answer)
        end
      end
    end

    def answer_value_from_params(param)
      return nil unless param.present?

      [].tap do |result|
        param.each_value do |group_params|
          result << fields.map.with_index do |field, i|
            field.answer_from_params(group_params[i.to_s])
          end
        end

        raise SurveyDef::SerializationError, "Answer is less than minimum!" if min && result.size < min
        raise SurveyDef::SerializationError, "Answer is greater than maximum!" if max && result.size > max
      end
    end

    def deserialize_answer_value(groups)
      unless groups.is_a?(Array)
        raise SurveyDef::SerializationError, "Type mismatched: expected Array, got #{groups.class}"
      end

      groups.map do |group|
        unless group.is_a?(Array)
          raise SurveyDef::SerializationError, "Type mismatched: expected Array, got #{group.class}"
        end

        if group.size != fields.size
          raise SurveyDef::SerializationError, "Grouped question count mismatch, expected #{fields.size}, got #{group.size}" # rubocop:disable Layout/LineLength
        end

        group.map.with_index { |answer, i| fields[i].deserialize_answer(answer) }
      end
    end

    def serialize(field_serializer = :serialize)
      super().tap do |result|
        result["min"] = min
        result["max"] = max
        result["fields"] = fields.map(&field_serializer)
      end
    end

    def to_answers_h
      serialize(:to_answers_h).tap do |result|
        result["blank"] = fields.map(&:blank_answer)
      end
    end

    private

    def initialize_from_params(hash)
      raise "Missing group fields!" unless hash[:fields]
      @min = hash[:min].to_i if hash[:min].present?
      @max = hash[:max].to_i if hash[:max].present?
      @fields = []

      hash[:fields].each_value do |field_param|
        @fields << SurveyDef::Definition.construct_field_from_param(field_param)
      end
    end

    def initialize_from_hash(hash)
      raise "Missing group fields!" unless hash["fields"]
      @min = hash["min"]
      @max = hash["max"]

      @fields = hash["fields"].map do |field_hash|
        SurveyDef::Definition.construct_field(field_hash)
      end
    end

    class Answer < SurveyDef::BaseAnswer
      def serialize
        value.map do |answers|
          answers.map(&:serialize)
        end
      end

      def template_name
        "group"
      end
    end
  end
end

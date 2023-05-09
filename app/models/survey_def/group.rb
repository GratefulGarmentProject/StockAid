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

    def serialize
      super.tap do |result|
        result["min"] = min
        result["max"] = max
        result["fields"] = fields.map(&:serialize)
      end
    end

    private

    def initialize_from_params(hash)
      raise "Missing group fields!" unless hash[:fields]
      @min = hash[:min].to_i if hash[:min].present?
      @max = hash[:max].to_i if hash[:max].present?
      @fields = []

      hash[:fields].each do |_key, field_param|
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
    end
  end
end

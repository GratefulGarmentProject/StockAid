module SurveyDef
  class Definition
    attr_reader :fields

    FIELDS = [
      SurveyDef::Group,
      SurveyDef::Integer,
      SurveyDef::LongText,
      SurveyDef::Select,
      SurveyDef::Text
    ].freeze

    FIELDS_BY_TYPE = FIELDS.index_by(&:type).freeze

    # Render the definition data as a hash which will then be converted to json
    # for the front end code to utilize
    def self.to_h
      {
        fields: FIELDS.map(&:to_h)
      }
    end

    def self.construct_field(hash)
      raise "Missing field is invalid!" unless hash
      type = FIELDS_BY_TYPE[hash["type"]]
      raise "Invalid field type: #{hash['type'].inspect}" unless type
      type.new(hash)
    end

    def self.from_params(params)
      new(params, params: true)
    end

    def self.construct_field_from_param(param)
      raise "Missing field is invalid!" unless param
      type = FIELDS_BY_TYPE[param[:type]]
      raise "Invalid field type: #{hash[:type].inspect}" unless type
      type.from_param(param)
    end

    def initialize(hash = nil, params: false)
      if params
        raise "Missing fields!" unless hash[:fields]
        @fields = []

        hash[:fields].each_value do |field_param|
          @fields << SurveyDef::Definition.construct_field_from_param(field_param)
        end
      elsif hash
        raise "Missing fields!" unless hash["fields"]

        @fields = hash["fields"].map do |field_hash|
          SurveyDef::Definition.construct_field(field_hash)
        end
      else
        @fields = []
      end
    end

    def blank_answers
      fields.map(&:blank_answer)
    end

    def deserialize_answers(array)
      raise SurveyDef::SerializationError, "Question count mismatch, expected #{fields.size}, got #{array.size}" if array.size != fields.size

      SurveyDef::Answers.new(array.map.with_index { |answer, i| fields[i].deserialize_answer(answer) })
    end

    def answers_from_params(params)
      SurveyDef::Answers.new(fields.map.with_index { |field, i| field.answer_from_params(params[i.to_s]) })
    end

    def to_answers_json
      to_answers_h.to_json
    end

    # This method is for the answers page to include both the definition and the
    # blank value definition, specifically for grouped questions (and especially
    # nested grouped questions) to initialize properly when adding a new value.
    def to_answers_h
      {
        "fields" => fields.map(&:to_answers_h)
      }
    end

    def serialize
      {
        "fields" => fields.map(&:serialize)
      }
    end
  end
end

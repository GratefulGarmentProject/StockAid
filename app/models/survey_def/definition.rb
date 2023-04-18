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
      raise "Invalid field type: #{hash["type"].inspect}" unless type
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

        hash[:fields].each do |_key, field_param|
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

    def deserialize_answers(array)
      raise SurveyDef::SerializationError.new("Question count mismatch, expected #{fields.size}, got #{array.size}") if array.size != fields.size
      SurveyDef::Answers.new(array.map.with_index { |answer, i| fields[i].deserialize_answer(answer) })
    end

    def serialize
      {
        "fields" => fields.map(&:serialize)
      }
    end
  end
end

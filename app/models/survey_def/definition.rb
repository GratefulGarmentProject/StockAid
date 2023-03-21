module SurveyDef
  class Definition
    attr_reader :fields

    def self.construct_field(hash)
      raise "Missing field is invalid!" unless hash

      type =
        case hash["type"]
        when "group"
          SurveyDef::Group
        when "integer"
          SurveyDef::Integer
        when "long_text"
          SurveyDef::LongText
        when "select"
          SurveyDef::Select
        when "text"
          SurveyDef::Text
        else
          raise "Invalid field type: #{hash["type"].inspect}"
        end

      type.new(hash)
    end

    def initialize(hash = nil)
      if hash
        raise "Missing fields!" unless hash["fields"]

        @fields = hash["fields"].map do |field_hash|
          SurveyDef::Definition.construct_field(field_hash)
        end
      else
        @fields = []
      end
    end

    def to_h
      {
        "fields" => fields.map(&:to_h)
      }
    end
  end
end

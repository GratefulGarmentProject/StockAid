module SurveyDef
  class Integer < SurveyDef::Base
    self.type = "integer"
    self.type_label = "Integer"
    attr_accessor :min, :max

    def initialize(hash = nil, params: false)
      super(hash, params: params)

      if params
        @min = hash[:min].to_i if hash[:min].present?
        @max = hash[:max].to_i if hash[:max].present?
      elsif hash
        @min = hash["min"]
        @max = hash["max"]
      end
    end

    def answer_value_from_params(param)
      return nil unless param.is_a?(String)
      return nil unless param =~ /\A-?\d+\z/

      value = param.to_i

      raise SurveyDef::SerializationError, "Answer is less than minimum!" if min && value < min
      raise SurveyDef::SerializationError, "Answer is greater than maximum!" if max && value > max

      value
    end

    def serialize
      super.tap do |result|
        result["min"] = min
        result["max"] = max
      end
    end

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = ::Integer
    end
  end
end

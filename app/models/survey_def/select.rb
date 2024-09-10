module SurveyDef
  class Select < SurveyDef::Base
    self.type = "select"
    self.type_label = "Dropdown of Options"
    attr_accessor :options

    def initialize(hash = nil, params: false)
      super

      @options =
        if params
          hash[:options].dup
        elsif hash
          hash["options"].dup
        else
          []
        end
    end

    def answer_value_from_params(param)
      return nil unless param.is_a?(String)
      return nil unless param =~ /\A-?\d+\z/

      value = param.to_i

      raise SurveyDef::SerializationError, "Answer is out of bounds!" if value < 0 || value >= options.size

      value
    end

    def serialize
      super.tap do |result|
        result["options"] = options
      end
    end

    class Answer < SurveyDef::BaseAnswer
      self.deserialized_class = ::Integer

      def display_value
        field.options[value] if value
      end
    end
  end
end

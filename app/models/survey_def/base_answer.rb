module SurveyDef
  class BaseAnswer
    attr_accessor :field, :value

    class << self
      attr_accessor :deserialized_class
    end

    def initialize(field = nil, value = nil)
      @field = field
      @value = value
    end

    def display_value
      value
    end

    def serialize
      value
    end

    def template_name
      "generic"
    end
  end
end

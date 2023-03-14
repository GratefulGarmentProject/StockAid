module SurveyDef
  class Definition
    attr_reader :fields

    def initialize(hash = nil)
      @fields = []
    end

    def to_h
      {}
    end
  end
end

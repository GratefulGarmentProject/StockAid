module SurveyDef
  class Group < SurveyDef::Base
    attr_accessor :min, :max
    attr_reader :fields

    def initialize(hash = nil)
      @fields = []
    end
  end
end

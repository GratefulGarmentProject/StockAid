module SurveyDef
  class Select < SurveyDef::Base
    attr_accessor :options

    def initialize(hash = nil)
      @options = []
    end
  end
end

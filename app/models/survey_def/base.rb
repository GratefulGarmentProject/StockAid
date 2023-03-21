module SurveyDef
  class Base
    attr_accessor :label

    class << self
      attr_accessor :type
    end

    def initialize(hash = nil)
      if hash
        raise "Missing field label!" unless hash["label"]
        @label = hash["label"]
      end
    end

    def type
      self.class.type
    end

    def to_h
      {
        "type" => type,
        "label" => label
      }
    end
  end
end

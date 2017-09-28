module StockAidException
  class DeletionError < StandardError
    def initialize(msg = "We were unable to be delete as requested. Please try again or contact a system administrator.")
      super(msg)
    end
  end
end

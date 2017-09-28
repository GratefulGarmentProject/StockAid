module StockAidException
  class DeletionError < StandardError
    def initialize(msg)
      msg ||= <<-eos
        We were unable to be delete as requested.
        Please try again or contact a system administrator.
      eos
      super(msg)
    end
  end
end

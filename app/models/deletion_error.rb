class DeletionError < StandardError
  def initialize(msg)
    super(msg.presence || <<-eos)
      We were unable to delete as requested.
      Please try again or contact a system administrator.
    eos
  end
end

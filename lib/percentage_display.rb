class PercentageDisplay
  attr_accessor :current_count, :total

  def initialize(total:, logger: Logger.new(STDOUT))
    @current_count = 0
    @percent_complete = 0
    @total = total

    @logger = logger
  end

  def update_percentage
    return if current_percent <= percent_complete
    self.percent_complete = current_percent
    logger.info ">> #{percent_complete}\% done"
  end

  def increment_counter(amount = 1)
    self.current_count += amount
  end

  private

  attr_accessor :percent_complete, :logger

  def current_percent
    ((current_count.to_f / total) * 100).round
  end
end

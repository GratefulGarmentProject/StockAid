class ErrorUtil
  def self.error_details(e)
    "(#{e.class}) #{e.message}\n  #{e.backtrace.join("\n  ")}"
  end
end

class FailedNetSuiteExport < ApplicationRecord
  def self.record_error(object, error)
    failure = new
    failure.export_type = object.class.to_s
    failure.record_id = object.id
    failure.failure_details = failure_details(failure, error)
    failure.save!
  rescue => e
    Rails.logger.error("Error recording NetSuite error (#{e.class}) #{e.message}\n  #{e.backtrace.join("\n  ")}")
  end

  def self.failure_details(failure, error)
    error.failure_details
  rescue
    "#{error.message} (#{error.class})\n  #{error.backtrace.join("\n  ")}"
  end
end

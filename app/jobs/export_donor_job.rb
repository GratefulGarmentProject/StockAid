class ExportDonorJob < ApplicationJob
  queue_as :default

  def perform(donor_id)
    donor = Donor.find(donor_id)

    begin
      NetSuiteIntegration.export_in_progress(donor)
      NetSuiteIntegration::DonorExporter.new(donor).export
    rescue => e
      FailedNetSuiteExport.record_error(donor, e)
      NetSuiteIntegration.export_failed(donor)
      Rails.logger.error("Error exporting donor #{donor.id}: (#{e.class}) #{e.message}\n  #{e.backtrace.join("\n  ")}")
    end
  end
end

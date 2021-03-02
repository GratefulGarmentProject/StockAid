class ExportDonationJob < ApplicationJob
  queue_as :default

  def perform(donation_id)
    donation = Donation.find(donation_id)

    begin
      NetSuiteIntegration.export_in_progress(donation)
      NetSuiteIntegration::DonationExporter.new(donation).export
    rescue => e
      NetSuiteIntegration.export_failed(donation)
      Rails.logger.error("Error exporting donation #{donation.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

class ExportDonationJob < ApplicationJob
  queue_as :default

  def perform(donation_id)
    donation = Donation.find(donation_id)
    raise "Donation #{donation.id} should not be synced" unless donation.can_be_synced?(syncing_now: true)

    begin
      NetSuiteIntegration.exports_in_progress(donation, additional_prefixes: :journal)
      NetSuiteIntegration::DonationExporter.new(donation).export
    rescue => e
      FailedNetSuiteExport.record_error(donation, e)
      NetSuiteIntegration.exports_failed(donation, additional_prefixes: :journal)
      Rails.logger.error("Error exporting donation #{donation.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

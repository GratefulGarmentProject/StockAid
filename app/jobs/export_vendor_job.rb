class ExportVendorJob < ApplicationJob
  queue_as :default

  def perform(vendor_id)
    vendor = Vendor.find(vendor_id)

    begin
      NetSuiteIntegration.export_in_progress(vendor)
      NetSuiteIntegration::VendorExporter.new(vendor).export
    rescue => e
      FailedNetSuiteExport.record_error(vendor, e)
      NetSuiteIntegration.export_failed(vendor)
      Rails.logger.error("Error exporting vendor #{vendor.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

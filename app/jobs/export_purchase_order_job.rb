class ExportPurchaseOrderJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)
    raise "Purchase #{purchase.id} should not be synced" unless purchase.can_be_synced?(syncing_now: true)

    begin
      NetSuiteIntegration.exports_in_progress(purchase, additional_prefixes: :variance)
      NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export
    rescue => e
      FailedNetSuiteExport.record_error(purchase, e)
      NetSuiteIntegration.exports_failed(purchase, additional_prefixes: :variance)
      Rails.logger.error("Error exporting purchase #{purchase.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

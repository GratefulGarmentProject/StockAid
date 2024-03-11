class ExportPurchaseOrderJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)
    raise "Purchase #{purchase.id} should not be synced" unless purchase.can_be_synced?(syncing_now: true)

    begin
      NetSuiteIntegration.export_in_progress(purchase) unless NetSuiteIntegration.exported_successfully?(purchase)
      NetSuiteIntegration.export_in_progress(purchase, prefix: :variance) unless NetSuiteIntegration.exported_successfully?(purchase, prefix: :variance)
      NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export
    rescue => e
      FailedNetSuiteExport.record_error(purchase, e)
      NetSuiteIntegration.export_failed(purchase) unless NetSuiteIntegration.exported_successfully?(purchase)
      NetSuiteIntegration.export_failed(purchase, prefix: :variance) unless NetSuiteIntegration.exported_successfully?(purchase, prefix: :variance)
      Rails.logger.error("Error exporting purchase #{purchase.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

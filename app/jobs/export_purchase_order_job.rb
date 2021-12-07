class ExportPurchaseOrderJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)

    begin
      NetSuiteIntegration.export_in_progress(purchase)
      NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export
    rescue => e
      FailedNetSuiteExport.record_error(purchase, e)
      NetSuiteIntegration.export_failed(purchase)
      Rails.logger.error("Error exporting purchase #{purchase.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

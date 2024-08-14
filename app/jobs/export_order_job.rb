class ExportOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    raise "Order #{order.id} should not be synced" unless order.can_be_synced?(syncing_now: true)

    begin
      NetSuiteIntegration.exports_in_progress(order, additional_prefixes: :journal)
      NetSuiteIntegration::OrderExporter.new(order).export
    rescue => e
      FailedNetSuiteExport.record_error(order, e)
      NetSuiteIntegration.exports_failed(order, additional_prefixes: :journal)
      Rails.logger.error("Error exporting order #{order.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end

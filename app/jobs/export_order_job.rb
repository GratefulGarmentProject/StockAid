class ExportOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    raise "Order #{order.id} should not be synced" unless order.can_be_synced?(syncing_now: true)

    begin
      NetSuiteIntegration.export_in_progress(order) unless NetSuiteIntegration.exported_successfully?(order)

      unless NetSuiteIntegration.exported_successfully?(order, prefix: :journal)
        NetSuiteIntegration.export_in_progress(order, prefix: :journal)
      end

      NetSuiteIntegration::OrderExporter.new(order).export
    rescue => e
      FailedNetSuiteExport.record_error(order, e)
      NetSuiteIntegration.export_failed(order) unless NetSuiteIntegration.exported_successfully?(order)

      unless NetSuiteIntegration.exported_successfully?(order, prefix: :journal)
        NetSuiteIntegration.export_failed(order, prefix: :journal)
      end

      Rails.logger.error("Error exporting order #{order.id}: (#{e.class}) #{e.message}\n  #{e.backtrace.join("\n  ")}")
    end
  end
end

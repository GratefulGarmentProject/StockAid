class ExportOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

    begin
      NetSuiteIntegration.export_in_progress(order)
      NetSuiteIntegration::OrderExporter.new(order).export
    rescue => e
      NetSuiteIntegration.export_failed(order)
      Rails.logger.error("Error exporting order #{order.id}: (#{e.class}) #{e.message}\n  #{e.backtrace.join("\n  ")}")
    end
  end
end

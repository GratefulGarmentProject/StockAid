module NetSuiteIntegration
  class OrderExporter
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1
    ACCOUNTS_RECEIVABLE_ID = 1053
    AGENCY_ORDERS_ID = 629
    PROGRAMS_DEPARTMENT_ID = 1
    PROGRAM_TYPE_ID = 109

    attr_reader :order, :invoice_record

    def initialize(order)
      @order = order
    end

    def export_later
      NetSuiteIntegration.export_queued(order)
      ExportOrderJob.perform_later(order.id)
    end

    def export
      initialize_invoice_record
      assign_native_netsuite_attributes
      add_invoice_items
      assign_memo
      export_to_netsuite
      invoice_record
    end

    private

    def initialize_invoice_record
      @invoice_record = NetSuite::Records::Invoice.new
    end

    def assign_native_netsuite_attributes
      invoice_record.tran_id = "#{tran_id_prefix}#{order.id}"
      invoice_record.external_id = order.id
      invoice_record.account = { internal_id: ACCOUNTS_RECEIVABLE_ID }
      invoice_record.entity = { internal_id: order.organization.external_id }
      invoice_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
      invoice_record.tran_date = order.order_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
    end

    def tran_id_prefix
      if Rails.env.production?
        "SAO-"
      else
        "SAO-TEST-"
      end
    end

    def add_invoice_items
      order.value_by_program.each do |program, total_value|
        invoice_record.item_list << NetSuite::Records::InvoiceItem.new.tap do |item|
          item.item = { internal_id: AGENCY_ORDERS_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
          item.quantity = 1
          item.rate = total_value
          item.custom_field_list.custcol_npo_suitekey = NetSuite::Records::CustomRecordRef.new(internal_id: program.external_id, type_id: PROGRAM_TYPE_ID)
        end
      end
    end

    def assign_memo
      if Rails.env.production?
        invoice_record.memo = "StockAid Order ##{order.id} synced at #{Time.now.to_s}"
      else
        invoice_record.memo = "This is a test - delete"
      end
    end

    def export_to_netsuite
      raise "Failed to export order!" unless invoice_record.add

      order.external_id = invoice_record.internal_id.to_i
      order.save!
    end
  end
end

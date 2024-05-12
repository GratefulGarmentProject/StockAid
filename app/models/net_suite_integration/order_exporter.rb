module NetSuiteIntegration
  class OrderExporter
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1
    ACCOUNTS_RECEIVABLE_ACCOUNT_ID = 1053 # 12999 A/R Clearing account
    INVENTORY_OUT_TO_AGENCIES_ACCOUNT_ID = 894 # 7010 Inventory out to Agencies
    AGENCY_ORDERS_ID = 629
    PROGRAM_SERVICES_ID = 2
    PROGRAM_SERVICES_TYPE_ID = 88
    PROGRAMS_DEPARTMENT_ID = 1
    PROGRAMS_PROGRAM_ID = 102
    PROGRAM_TYPE_ID = 109
    PROGRAMS_CLASS_ID = 7
    IN_KIND_CONTRIBUTION = 2
    CONTRIBUTION_TYPE_ID = 162

    attr_reader :order, :invoice_record

    def initialize(order)
      @order = order
    end

    def export_later
      NetSuiteIntegration.exports_queued(order, additional_prefixes: :journal)
      ExportOrderJob.perform_later(order.id)
    end

    def export
      raise "Order #{order.id} should not be synced" unless order.can_be_synced?(syncing_now: true)
      find_region
      invoice_record = invoice_exporter.export
      journal_entry_record = journal_entry_exporter.export
      [invoice_record, journal_entry_record]
    end

    private

    def invoice_exporter
      NetSuiteIntegration::OrderExporter::InvoiceExporter.new(order, @region)
    end

    def journal_entry_exporter
      NetSuiteIntegration::OrderExporter::JournalEntryExporter.new(order, @region)
    end

    def find_region
      @region = NetSuiteIntegration::Region.find(order.organization.county)
    end

    # This class should only be used internally by the order exporter. It is
    # used by the parent exporter to export the invoice portion of the order.
    class InvoiceExporter
      attr_reader :order, :invoice_record

      def initialize(order, region)
        @order = order
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(order)
          Rails.logger.warn "Order #{order.id} invoice already exported"
          return
        end

        initialize_invoice_record
        assign_native_netsuite_attributes
        add_invoice_items
        assign_memo
        export_to_netsuite
        invoice_record
      end

      def initialize_invoice_record
        @invoice_record = NetSuite::Records::Invoice.new
      end

      def assign_native_netsuite_attributes
        invoice_record.tran_id = "#{tran_id_prefix}#{order.id}"
        invoice_record.external_id = "#{tran_id_prefix}#{order.id}"
        invoice_record.account = { internal_id: ACCOUNTS_RECEIVABLE_ACCOUNT_ID }
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
            item.custom_field_list.custcol_npo_suitekey =
              NetSuite::Records::CustomRecordRef.new(internal_id: program.external_id, type_id: PROGRAM_TYPE_ID)
            item.custom_field_list.custcol_tggp_contribution_type =
              NetSuite::Records::CustomRecordRef.new(internal_id: IN_KIND_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
            @region.assign_to(item)
            item.klass = { internal_id: program.external_class_id }
          end
        end
      end

      def assign_memo
        invoice_record.memo =
          if Rails.env.production?
            "StockAid Order ##{order.id} synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        raise NetSuiteIntegration::ExportError.new("Failed to export order!", invoice_record) unless invoice_record.add

        order.external_id = invoice_record.internal_id.to_i
        order.save!
      end
    end

    # This class should only be used internally by the order exporter. It is
    # used by the parent exporter to export the journal entry portion of the
    # order.
    class JournalEntryExporter
      attr_reader :order, :journal_entry_record

      def initialize(order, region)
        @order = order
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(order, prefix: :journal)
          Rails.logger.warn "Order #{order.id} journal entry already exported"
          return
        end

        initialize_journal_entry_record
        assign_native_netsuite_attributes
        add_line_items
        assign_memo
        export_to_netsuite
        journal_entry_record
      end

      private

      def initialize_journal_entry_record
        @journal_entry_record = NetSuite::Records::JournalEntry.new
      end

      def assign_native_netsuite_attributes
        journal_entry_record.tran_id = "#{tran_id_prefix}#{order.id}"
        journal_entry_record.external_id = "#{tran_id_prefix}#{order.id}"
        journal_entry_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
        journal_entry_record.tran_date = order.order_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
      end

      def add_line_items
        total_value = order.value

        journal_entry_record.line_list << NetSuite::Records::JournalEntryLine.new.tap do |item|
          item.account = { internal_id: ACCOUNTS_RECEIVABLE_ACCOUNT_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
          item.credit = total_value
          item.custom_field_list.custcol_cseg_npo_exp_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAM_SERVICES_ID, type_id: PROGRAM_SERVICES_TYPE_ID)
          item.custom_field_list.custcol_npo_suitekey =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAMS_PROGRAM_ID, type_id: PROGRAM_TYPE_ID)
          item.custom_field_list.custcol_tggp_contribution_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: IN_KIND_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
          @region.assign_to(item)
          item.klass = { internal_id: PROGRAMS_CLASS_ID }
        end

        journal_entry_record.line_list << NetSuite::Records::JournalEntryLine.new.tap do |item|
          item.account = { internal_id: INVENTORY_OUT_TO_AGENCIES_ACCOUNT_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
          item.debit = total_value
          item.custom_field_list.custcol_cseg_npo_exp_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAM_SERVICES_ID, type_id: PROGRAM_SERVICES_TYPE_ID)
          item.custom_field_list.custcol_npo_suitekey =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAMS_PROGRAM_ID, type_id: PROGRAM_TYPE_ID)
          item.custom_field_list.custcol_tggp_contribution_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: IN_KIND_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
          @region.assign_to(item)
          item.klass = { internal_id: PROGRAMS_CLASS_ID }
        end
      end

      def tran_id_prefix
        if Rails.env.production?
          "SAOJE-"
        else
          "SAOJE-TEST-"
        end
      end

      def assign_memo
        journal_entry_record.memo =
          if Rails.env.production?
            "StockAid Order ##{order.id} Journal Entry synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        unless journal_entry_record.add
          raise NetSuiteIntegration::ExportError.new("Failed to export order journal entry!", journal_entry_record)
        end

        order.journal_external_id = journal_entry_record.internal_id.to_i
        order.save!
      end
    end
  end
end

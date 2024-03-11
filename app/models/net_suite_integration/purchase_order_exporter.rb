 module NetSuiteIntegration
  class PurchaseOrderExporter
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1
    ACCOUNTS_PAYABLE_ACCOUNT_ID = 529 # 2010 Payables : Accounts Payable
    INVENTORY_COGS_ACCOUNT_ID = 892 # 6010 Inventory COGS
    PPV_ACCOUNT_ID = 1056 # 6020 Cost of Goods Sold : Purchase Price Variance
    INVENTORY_ASSET_ACCOUNT_ID = 214 # 4999 Inventory Asset
    INVENTORY_CATEGORY_ID = 43 # Inventory
    PROGRAM_SERVICES_ID = 2
    PROGRAM_SERVICES_TYPE_ID = 88
    PROGRAMS_DEPARTMENT_ID = 1
    PROGRAM_TYPE_ID = 109
    PROGRAMS_PROGRAM_ID = 102
    PROGRAMS_CLASS_ID = 7
    MONETARY_CONTRIBUTION = 1
    CONTRIBUTION_TYPE_ID = 162

    attr_reader :purchase

    def initialize(purchase)
      @purchase = purchase
    end

    def export_later
      NetSuiteIntegration.export_queued(purchase) unless NetSuiteIntegration.exported_successfully?(purchase)
      NetSuiteIntegration.export_queued(purchase, prefix: :variance) unless NetSuiteIntegration.exported_successfully?(purchase, prefix: :variance)
      ExportPurchaseOrderJob.perform_later(purchase.id)
    end

    def export
      raise "Purchase #{purchase.id} should not be synced" unless purchase.can_be_synced?(syncing_now: true)
      find_region
      vendor_bill_record = NetSuiteIntegration::PurchaseOrderExporter::VendorBillExporter.new(purchase, @region).export
      journal_entry_record = NetSuiteIntegration::PurchaseOrderExporter::JournalEntryExporter.new(purchase, @region).export
      [vendor_bill_record, journal_entry_record]
    end

    private

    def find_region
      @region = NetSuiteIntegration::Region.find_default
    end

    # This class should only be used internally by the purchase order
    # exporter. It is used by the parent exporter to export the vendor bill
    # portion of the purchase order (the bulk of the purchase order).
    class VendorBillExporter
      attr_reader :purchase, :vendor_bill_record

      def initialize(purchase, region)
        @purchase = purchase
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(purchase)
          Rails.logger.warn "Purchase #{purchase.id} vendor bill already exported"
          return
        end

        initialize_vendor_bill_record
        assign_native_netsuite_attributes
        add_vendor_bill_items
        assign_memo
        export_to_netsuite
        vendor_bill_record
      end

      private

      def initialize_vendor_bill_record
        @vendor_bill_record = NetSuite::Records::VendorBill.new
      end

      def assign_native_netsuite_attributes
        vendor_bill_record.tran_id = "#{tran_id_prefix}#{purchase.id}"
        vendor_bill_record.external_id = "#{tran_id_prefix}#{purchase.id}"
        vendor_bill_record.account = { internal_id: ACCOUNTS_PAYABLE_ACCOUNT_ID }
        vendor_bill_record.entity = { internal_id: purchase.vendor.external_id }
        vendor_bill_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
        vendor_bill_record.tran_date = purchase.purchase_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
      end

      def add_vendor_bill_items # rubocop:disable Metrics/AbcSize
        purchase.value_by_program.each do |program, total_value|
          vendor_bill_record.expense_list << NetSuite::Records::VendorBillExpense.new.tap do |item|
            item.category = { internal_id: INVENTORY_CATEGORY_ID }
            item.account = { internal_id: INVENTORY_COGS_ACCOUNT_ID }
            item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
            item.amount = total_value
            item.custom_field_list.custcol_cseg_npo_exp_type =
              NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAM_SERVICES_ID, type_id: PROGRAM_SERVICES_TYPE_ID)
            item.custom_field_list.custcol_npo_suitekey =
              NetSuite::Records::CustomRecordRef.new(internal_id: program.external_id, type_id: PROGRAM_TYPE_ID)
            item.custom_field_list.custcol_tggp_contribution_type =
              NetSuite::Records::CustomRecordRef.new(internal_id: MONETARY_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
            @region.assign_to(item)
            item.klass = { internal_id: program.external_class_id }
          end
        end
      end

      def tran_id_prefix
        if Rails.env.production?
          "SAPO-"
        else
          "SAPO-TEST-"
        end
      end

      def assign_memo
        vendor_bill_record.memo =
          if Rails.env.production?
            "StockAid Purchase Order ##{purchase.id} synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        unless vendor_bill_record.add
          raise NetSuiteIntegration::ExportError.new("Failed to export purchase order!", vendor_bill_record)
        end

        purchase.external_id = vendor_bill_record.internal_id.to_i
        purchase.save!
      end
    end

    # This class should only be used internally by the purchase order
    # exporter. It is used by the parent exporter to export the journal entry
    # portion of the purchase order (which is used to capture the price point
    # variance).
    class JournalEntryExporter
      attr_reader :purchase, :journal_entry_record

      def initialize(purchase, region)
        @purchase = purchase
        @total_ppv = purchase.total_ppv
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(purchase, prefix: :variance)
          Rails.logger.warn "Purchase #{purchase.id} journal entry already exported"
          return
        end

        if @total_ppv.zero?
          NetSuiteIntegration.export_not_applicable(purchase, prefix: :variance)
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
        journal_entry_record.tran_id = "#{tran_id_prefix}#{purchase.id}"
        journal_entry_record.external_id = "#{tran_id_prefix}#{purchase.id}"
        journal_entry_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
        journal_entry_record.tran_date = purchase.purchase_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
      end

      def add_line_items
        journal_entry_record.line_list << NetSuite::Records::JournalEntryLine.new.tap do |item|
          item.account = { internal_id: PPV_ACCOUNT_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }

          if @total_ppv < 0
            item.debit = -@total_ppv
          else
            item.credit = @total_ppv
          end

          item.custom_field_list.custcol_cseg_npo_exp_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAM_SERVICES_ID, type_id: PROGRAM_SERVICES_TYPE_ID)
          item.custom_field_list.custcol_npo_suitekey =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAMS_PROGRAM_ID, type_id: PROGRAM_TYPE_ID)
          item.custom_field_list.custcol_tggp_contribution_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: MONETARY_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
          @region.assign_to(item)
          item.klass = { internal_id: PROGRAMS_CLASS_ID }
        end

        journal_entry_record.line_list << NetSuite::Records::JournalEntryLine.new.tap do |item|
          item.account = { internal_id: INVENTORY_ASSET_ACCOUNT_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }

          if @total_ppv < 0
            item.credit = -@total_ppv
          else
            item.debit = @total_ppv
          end

          item.custom_field_list.custcol_cseg_npo_exp_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAM_SERVICES_ID, type_id: PROGRAM_SERVICES_TYPE_ID)
          item.custom_field_list.custcol_npo_suitekey =
            NetSuite::Records::CustomRecordRef.new(internal_id: PROGRAMS_PROGRAM_ID, type_id: PROGRAM_TYPE_ID)
          item.custom_field_list.custcol_tggp_contribution_type =
            NetSuite::Records::CustomRecordRef.new(internal_id: MONETARY_CONTRIBUTION, type_id: CONTRIBUTION_TYPE_ID)
          @region.assign_to(item)
          item.klass = { internal_id: PROGRAMS_CLASS_ID }
        end
      end

      def tran_id_prefix
        if Rails.env.production?
          "SAPOPPV-"
        else
          "SAPOPPV-TEST-"
        end
      end

      def assign_memo
        journal_entry_record.memo =
          if Rails.env.production?
            "StockAid Purchase Order ##{purchase.id} PPV synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        unless journal_entry_record.add
          raise NetSuiteIntegration::ExportError.new("Failed to export purchase order PPV!", journal_entry_record)
        end

        purchase.variance_external_id = journal_entry_record.internal_id.to_i
        purchase.save!
      end
    end
  end
end

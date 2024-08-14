module NetSuiteIntegration
  class DonationExporter
    IN_KIND_DONATION_RECEIVED_ID = 628
    IN_KIND_DONATION_CLEARING_ACCOUNT_ID = 1052 # 99999 In-Kind Donation - Clearing
    IN_KIND_DONATIONS_ACCOUNT_ID = 878
    INVENTORY_ASSET_ACCOUNT_ID = 214 # 4999 Inventory Asset
    IN_KIND_CONTRIBUTION = 2
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1
    TGGP_CALIFORNIA_LOCATION_ID = 1
    PROGRAMS_CLASS_ID = 7
    PROGRAMS_DEPARTMENT_ID = 1
    PROGRAMS_PROGRAM_ID = 102
    PROGRAM_SERVICES_ID = 2
    PROGRAM_SERVICES_TYPE_ID = 88
    PROGRAM_TYPE_ID = 109
    CONTRIBUTION_TYPE_ID = 162
    CONTRIBUTION_TYPE_IN_KIND_INTERNAL_ID = 2
    REVENUE_STREAM_TYPE_ID = 662

    attr_reader :donation

    def initialize(donation)
      @donation = donation
    end

    def export_later
      NetSuiteIntegration.exports_queued(donation, additional_prefixes: :journal)
      ExportDonationJob.perform_later(donation.id)
    end

    def export
      raise "Donation #{donation.id} should not be synced" unless donation.can_be_synced?(syncing_now: true)
      find_region
      cash_sale_record = cash_sale_exporter.export
      journal_entry_record = journal_entry_exporter.export
      [cash_sale_record, journal_entry_record]
    end

    private

    def cash_sale_exporter
      NetSuiteIntegration::DonationExporter::CashSaleExporter.new(donation, @region)
    end

    def journal_entry_exporter
      NetSuiteIntegration::DonationExporter::JournalEntryExporter.new(donation, @region)
    end

    def find_region
      @region = NetSuiteIntegration::Region.find_default
    end

    # This class should only be used internally by the donation exporter. It is
    # used by the parent exporter to export the cash sale portion of the donation.
    class CashSaleExporter
      attr_reader :donation, :cash_sale_record

      def initialize(donation, region)
        @donation = donation
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(donation)
          Rails.logger.warn "Donation #{donation.id} cash sale already exported"
          return
        end

        initialize_cash_sale_record
        assign_native_netsuite_attributes
        add_cash_sale_items
        assign_memo
        export_to_netsuite
        cash_sale_record
      end

      def initialize_cash_sale_record
        @cash_sale_record = NetSuite::Records::CashSale.new
      end

      def assign_native_netsuite_attributes # rubocop:disable Metrics/AbcSize
        cash_sale_record.tran_id = "#{tran_id_prefix}#{donation.id}"
        cash_sale_record.external_id = "#{tran_id_prefix}#{donation.id}"
        cash_sale_record.location = { internal_id: TGGP_CALIFORNIA_LOCATION_ID }
        cash_sale_record.account = { internal_id: IN_KIND_DONATION_CLEARING_ACCOUNT_ID }
        cash_sale_record.entity = { internal_id: donation.donor.external_id }
        cash_sale_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
        cash_sale_record.tran_date = donation.donation_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
        # This checks an "in-kind" checkbox for the donation as a whole in NetSuite
        cash_sale_record.custom_field_list.custbody1 = true
      end

      def tran_id_prefix
        if Rails.env.production?
          "SAI-"
        else
          "SAI-TEST-"
        end
      end

      def add_cash_sale_items # rubocop:disable Metrics/AbcSize
        donation.value_by_program.each do |program, total_value|
          cash_sale_record.item_list << NetSuite::Records::CashSaleItem.new.tap do |item|
            item.item = { internal_id: IN_KIND_DONATION_RECEIVED_ID }
            item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
            item.quantity = 1
            item.rate = total_value
            item.custom_field_list.custcol_npo_suitekey =
              NetSuite::Records::CustomRecordRef.new(internal_id: program.external_id, type_id: PROGRAM_TYPE_ID)
            item.custom_field_list.custcol_tggp_contribution_type =
              NetSuite::Records::CustomRecordRef.new(internal_id: CONTRIBUTION_TYPE_IN_KIND_INTERNAL_ID,
                                                     type_id: CONTRIBUTION_TYPE_ID)
            item.custom_field_list.custcol_cseg_npo_rev_type =
              NetSuite::Records::CustomRecordRef.new(internal_id: donation.revenue_stream.external_id,
                                                     type_id: REVENUE_STREAM_TYPE_ID)
            @region.assign_to(item)
            item.klass = { internal_id: program.external_class_id }
          end
        end
      end

      def assign_memo
        cash_sale_record.memo =
          if Rails.env.production?
            "StockAid Donation ##{donation.id} synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        unless cash_sale_record.add
          raise NetSuiteIntegration::ExportError.new("Failed to export donation!", cash_sale_record)
        end

        donation.external_id = cash_sale_record.internal_id.to_i
        donation.save!
      end
    end

    # This class should only be used internally by the donation exporter. It is
    # used by the parent exporter to export the journal entry portion of the
    # donation.
    class JournalEntryExporter
      attr_reader :donation, :journal_entry_record

      def initialize(donation, region)
        @donation = donation
        @region = region
      end

      def export
        if NetSuiteIntegration.exported_successfully?(donation, prefix: :journal)
          Rails.logger.warn "Donation #{donation.id} journal entry already exported"
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
        journal_entry_record.tran_id = "#{tran_id_prefix}#{donation.id}"
        journal_entry_record.external_id = "#{tran_id_prefix}#{donation.id}"
        journal_entry_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
        journal_entry_record.tran_date = donation.donation_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
      end

      def add_line_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        total_value = donation.value

        journal_entry_record.line_list << NetSuite::Records::JournalEntryLine.new.tap do |item|
          item.account = { internal_id: IN_KIND_DONATION_CLEARING_ACCOUNT_ID }
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
          item.account = { internal_id: INVENTORY_ASSET_ACCOUNT_ID }
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
          "SAIJE-"
        else
          "SAIJE-TEST-"
        end
      end

      def assign_memo
        journal_entry_record.memo =
          if Rails.env.production?
            "StockAid Donation ##{donation.id} Journal Entry synced at #{Time.zone.now}"
          else
            "This is a test - delete"
          end
      end

      def export_to_netsuite
        unless journal_entry_record.add
          raise NetSuiteIntegration::ExportError.new("Failed to export donation journal entry!", journal_entry_record)
        end

        donation.journal_external_id = journal_entry_record.internal_id.to_i
        donation.save!
      end
    end
  end
end

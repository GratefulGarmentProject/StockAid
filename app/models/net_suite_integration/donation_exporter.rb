module NetSuiteIntegration
  class DonationExporter
    IN_KIND_DONATION_RECEIVED_ID = 628
    IN_KIND_DONATION_CLEARING_ACCOUNT_ID = 1052 # 99999 In-Kind Donation - Clearing
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1
    TGGP_CALIFORNIA_LOCATION_ID = 1
    PROGRAMS_DEPARTMENT_ID = 1
    PROGRAM_TYPE_ID = 109

    attr_reader :donation, :cash_sale_record

    def initialize(donation)
      @donation = donation
    end

    def export_later
      NetSuiteIntegration.export_queued(donation)
      ExportDonationJob.perform_later(donation.id)
    end

    def export
      initialize_cash_sale_record
      assign_native_netsuite_attributes
      add_cash_sale_items
      assign_memo
      export_to_netsuite
      cash_sale_record
    end

    private

    def initialize_cash_sale_record
      @cash_sale_record = NetSuite::Records::CashSale.new
    end

    def assign_native_netsuite_attributes
      cash_sale_record.tran_id = "#{tran_id_prefix}#{donation.id}"
      cash_sale_record.external_id = donation.id
      cash_sale_record.location = { internal_id: TGGP_CALIFORNIA_LOCATION_ID }
      cash_sale_record.account = { internal_id: IN_KIND_DONATION_CLEARING_ACCOUNT_ID }
      cash_sale_record.entity = { internal_id: donation.donor.external_id }
      cash_sale_record.subsidiary = { internal_id: GRATEFUL_GARMENT_SUBSIDIARY_ID }
      cash_sale_record.tran_date = donation.donation_date.strftime "%Y-%m-%dT%H:%M:%S.%L%z"
    end

    def tran_id_prefix
      if Rails.env.production?
        "SA$-"
      else
        "SA$-TEST-"
      end
    end

    def add_cash_sale_items
      donation.value_by_program.each do |program, total_value|
        cash_sale_record.item_list << NetSuite::Records::CashSaleItem.new.tap do |item|
          item.item = { internal_id: IN_KIND_DONATION_RECEIVED_ID }
          item.department = { internal_id: PROGRAMS_DEPARTMENT_ID }
          item.quantity = 1
          item.rate = total_value
          item.custom_field_list.custcol_npo_suitekey =
            NetSuite::Records::CustomRecordRef.new(internal_id: program.external_id, type_id: PROGRAM_TYPE_ID)
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
      raise "Failed to export donation!" unless cash_sale_record.add

      donation.external_id = cash_sale_record.internal_id.to_i
      donation.save!
    end
  end
end

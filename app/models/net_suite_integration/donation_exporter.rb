module NetSuiteIntegration
  class DonationExporter
    IN_KIND_DONATIONS_ACCOUNT_ID = 846 # Contributions Receivable -> In-Kind Donations
    GRATEFUL_GARMENT_SUBSIDIARY_ID = 1

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
      cash_sale_record.account = { internal_id: IN_KIND_DONATIONS_ACCOUNT_ID }
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
      raise "TODO: Add donation items"
    end

    def assign_memo
      if Rails.env.production?
        cash_sale_record.memo = "StockAid Donation ##{donation.id} synced at #{Time.now.to_s}"
      else
        cash_sale_record.memo = "This is a test - delete"
      end
    end

    def export_to_netsuite
      raise "Failed to export donation!" unless cash_sale_record.add

      donation.external_id = cash_sale_record.internal_id.to_i
      donation.save!
    end
  end
end

module NetSuiteIntegration
  class PurchaseOrderExporter
    attr_reader :purchase, :vendor_bill_record

    def initialize(purchase)
      @purchase = purchase
    end

    def export_later
      NetSuiteIntegration.export_queued(purchase)
      ExportPurchaseOrderJob.perform_later(purchase.id)
    end

    def export
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
      vendor_bill_record.external_id = purchase.id
      raise "TODO"
    end

    def add_vendor_bill_items
      raise "TODO"
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
      raise "Failed to export purchase order!" unless vendor_bill_record.add

      purchase.external_id = vendor_bill_record.internal_id.to_i
      purchase.save!
    end
  end
end

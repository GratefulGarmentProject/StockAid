module NetSuiteIntegration
  class VendorExporter
    INVENTORY_CATEGORY_ID = 5

    attr_reader :vendor, :vendor_record
    private(*delegate(:netsuite_address, :grateful_garment_subsidiary, # rubocop:disable Style/AccessModifierDeclarations
                      to: "NetSuiteIntegration::Constituent"))

    def self.create_and_export(vendor_params, save_and_export)
      Vendor.transaction do
        vendor = Vendor.create!(vendor_params)
        new(vendor).export_later if save_and_export
        vendor
      end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    def export_later
      NetSuiteIntegration.export_queued(vendor)
      ExportVendorJob.perform_later(vendor.id)
    end

    def export
      initialize_vendor_record
      assign_name_attributes
      assign_native_netsuite_attributes
      assign_netsuite_address
      export_to_netsuite
      vendor_record
    end

    private

    def initialize_vendor_record
      @vendor_record = NetSuite::Records::Vendor.new
    end

    def person?
      vendor.external_type == NetSuiteIntegration::NetSuiteVendor::INDIVIDUAL
    end

    def assign_name_attributes
      vendor_record.is_person = person?

      if person?
        name_parts = vendor.name.split(" ", 3)
        vendor_record.first_name = name_parts.first
        vendor_record.middle_name = name_parts[1] if name_parts.size > 2
        vendor_record.last_name = name_parts.last if name_parts.size > 1
      else
        vendor_record.company_name = vendor.name
      end
    end

    def assign_native_netsuite_attributes
      vendor_record.subsidiary = grateful_garment_subsidiary
      vendor_record.email = vendor.email
      vendor_record.phone = vendor.phone_number
      vendor_record.category = { internal_id: INVENTORY_CATEGORY_ID }
    end

    def assign_netsuite_address
      address = netsuite_address(vendor.addresses.first)
      vendor_record.addressbook_list.addressbook << address if address
    end

    def export_to_netsuite
      raise NetSuiteIntegration::ExportError.new("Failed to export vendor!", vendor_record) unless vendor_record.add

      vendor.external_id = vendor_record.internal_id.to_i
      vendor.save!
    end
  end
end

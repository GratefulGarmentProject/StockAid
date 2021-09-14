module NetSuiteIntegration
  class VendorImporter
    attr_reader :netsuite_id, :netsuite_vendor

    def initialize(params)
      @netsuite_id = params.require(:external_id).to_i
    end

    def import
      @netsuite_vendor = fetch_vendor
      create_vendor
    end

    private

    def fetch_vendor
      NetSuiteIntegration::NetSuiteVendor.by_id(netsuite_id)
    rescue NetSuite::RecordNotFound
      record_for_error = Vendor.new(external_id: netsuite_id)
      record_for_error.errors.add(:base, "Could not find NetSuite Vendor with NetSuite ID #{netsuite_id}")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    def create_vendor
      Vendor.create! do |vendor|
        vendor.name = netsuite_vendor.name
        vendor.website = ""
        vendor.contact_name = ""
        vendor.external_id = netsuite_vendor.netsuite_id
        vendor.external_type = netsuite_vendor.type
        vendor.email = netsuite_vendor.email
        vendor.phone_number = netsuite_vendor.phone

        netsuite_address = netsuite_vendor.address
        if netsuite_address
          # netsuite_address will be a hash with the proper address parts
          vendor.addresses.build(netsuite_address)
        end
      end
    end
  end
end

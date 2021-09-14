module NetSuiteIntegration
  class NetSuiteVendor
    INDIVIDUAL = "Individual".freeze
    COMPANY = "Company".freeze
    EXTERNAL_TYPES = [COMPANY, INDIVIDUAL].freeze

    def self.by_id(id)
      new(NetSuite::Records::Vendor.get(internal_id: id))
    end

    def initialize(netsuite_record)
      @netsuite_record = netsuite_record
    end

    def netsuite_id
      @netsuite_record.internal_id.to_i
    end

    def name
      if @netsuite_record.is_person
        [@netsuite_record.first_name, @netsuite_record.middle_name, @netsuite_record.last_name].compact.join(" ")
      else
        @netsuite_record.company_name
      end
    end

    def type
      if @netsuite_record.is_person
        INDIVIDUAL
      else
        COMPANY
      end
    end

    def email
      @netsuite_record.email
    end

    def phone
      @netsuite_record.phone || @netsuite_record.mobile_phone
    end

    def address
      netsuite_address = @netsuite_record.addressbook_list.addressbook[0]

      return unless netsuite_address

      {
        street_address: netsuite_address.addressbook_address.addr1,
        city: netsuite_address.addressbook_address.city,
        state: netsuite_address.addressbook_address.state,
        zip: netsuite_address.addressbook_address.zip
      }
    end
  end
end

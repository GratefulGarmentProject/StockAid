module NetSuiteIntegration
  class Constituent
    # NetSuite types to their internal id values
    NETSUITE_TYPES = {
      "Individual" => "3",
      "Organization" => "1",
      "Company" => "6",
      "Agency" => "4",
      "Funding Source" => "7",
      "Household" => "2",
      "Service Provider" => "5",
      "Board of Director" => "8"
    }.freeze

    def self.by_id(id)
      new(NetSuite::Records::Customer.get(internal_id: id))
    end

    def self.netsuite_address(address)
      return unless address

      if address.all_parts_present?
        NetSuite::Records::CustomerAddressbook.new(
          addressbook_address: {
            addr1: address.street_address,
            city: address.city,
            state: address.state,
            zip: address.zip
          }
        )
      elsif address.address.match?(/\A([^,]*), ([^,]*), (\w\w) (\d+)\z/)
        NetSuite::Records::CustomerAddressbook.new(
          addressbook_address: {
            addr1: Regexp.last_match[1],
            city: Regexp.last_match[2],
            state: Regexp.last_match[3],
            zip: Regexp.last_match[4]
          }
        )
      end
    end

    def self.grateful_garment_subsidiary
      { internal_id: "1" }
    end

    def self.netsuite_type(value)
      internal_id = NETSUITE_TYPES[value]
      raise "Unknown NetSuite type: #{value}" if internal_id.blank?
      { internal_id: internal_id }
    end

    def self.netsuite_profile(value)
      case value
      when "Agency"
        NetSuite::Records::CustomRecordRef.new(internal_id: "8")
      when "Donor"
        NetSuite::Records::CustomRecordRef.new(internal_id: "9")
      else
        raise "Unknown NetSuite profile: #{value}"
      end
    end

    def self.netsuite_classification(value)
      case value
      when "Agency"
        NetSuite::Records::CustomRecordRef.new(internal_id: "8")
      when "Donor"
        NetSuite::Records::CustomRecordRef.new(internal_id: "1")
      else
        raise "Unknown NetSuite classification: #{value}"
      end
    end

    def initialize(netsuite_record)
      @netsuite_record = netsuite_record
    end

    def donor?
      @netsuite_record.custom_field_list.custentity_npo_constituent_profile.value.any? { |x| x.name.strip == "Donor" }
    end

    def organization?
      @netsuite_record.custom_field_list.custentity_npo_constituent_profile.value.any? { |x| x.name.strip == "Agency" }
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
      @netsuite_record.custom_field_list.custentity_npo_constituent_type.value.name
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

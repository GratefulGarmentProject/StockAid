class NetSuiteConstituent
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

  def self.export_donor(donor)
    record = NetSuite::Records::Customer.new
    record.is_person = true

    name_parts = donor.name.split(" ", 3)
    record.first_name = name_parts.first
    record.middle_name = name_parts[1] if name_parts.size > 2
    record.last_name = name_parts.last if name_parts.size > 1

    record.email = donor.email
    record.phone = donor.phone_number
    record.custom_field_list.custentity_npo_constituent_type = netsuite_type(donor.external_type)
    record.custom_field_list.custentity_npo_constituent_profile = [netsuite_profile("Donor")]
    record.custom_field_list.custentity_npo_txn_classification = [netsuite_classification("Donor")]

    address = netsuite_address(donor.addresses.first)
    record.addressbook_list.addressbook << address if address

    unless record.add
      raise "Failed to export donor!"
    end

    donor.external_id = record.internal_id.to_i
    donor.save!
    record
  end

  def self.export_organization(organization)
    record = NetSuite::Records::Customer.new
    record.is_person = false

    record.company_name = organization.name
    record.email = organization.email
    record.phone = organization.phone_number
    record.custom_field_list.custentity_npo_constituent_type = netsuite_type(organization.external_type)
    record.custom_field_list.custentity_npo_constituent_profile = [netsuite_profile("Agency")]
    record.custom_field_list.custentity_npo_txn_classification = [netsuite_classification("Agency")]

    address = netsuite_address(organization.addresses.first)
    record.addressbook_list.addressbook << address if address

    unless record.add
      raise "Failed to export organization!"
    end

    organization.external_id = record.internal_id.to_i
    organization.save!
    record
  end

  def self.netsuite_address(address)
    return unless address

    if address.parts_present?
      NetSuite::Records::CustomerAddressbook.new(addressbook_address: {
        addr1: address.street_address,
        city: address.city,
        state: address.state,
        zip: address.zip
      })
    elsif address.address =~ /\A([^,]*), ([^,]*), (\w\w) (\d+)\z/
      NetSuite::Records::CustomerAddressbook.new(addressbook_address: {
        addr1: Regexp.last_match[1],
        city: Regexp.last_match[2],
        state: Regexp.last_match[3],
        zip: Regexp.last_match[4]
      })
    end
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

    if netsuite_address
      {
        street_address: netsuite_address.addressbook_address.addr1,
        city: netsuite_address.addressbook_address.city,
        state: netsuite_address.addressbook_address.state,
        zip: netsuite_address.addressbook_address.zip
      }
    end
  end
end

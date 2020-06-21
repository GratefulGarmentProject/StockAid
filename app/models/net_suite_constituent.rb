class NetSuiteConstituent
  def self.by_id(id)
    new(NetSuite::Records::Customer.get(internal_id: id))
  end

  def initialize(netsuite_record)
    @netsuite_record = netsuite_record
  end

  def donor?
    @netsuite_record.custom_field_list.custentity_npo_constituent_profile.value.any? { |x| x.name.strip == "Donor" }
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
      addr1 = netsuite_address.addressbook_address.addr1
      city = netsuite_address.addressbook_address.city
      state = netsuite_address.addressbook_address.state
      zip = netsuite_address.addressbook_address.zip
      "#{addr1}, #{city}, #{state} #{zip}"
    end
  end
end

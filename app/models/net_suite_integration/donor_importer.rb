class NetSuiteIntegration::DonorImporter
  attr_reader :netsuite_id, :netsuite_donor

  def initialize(params)
    @netsuite_id = params.require(:external_id).to_i
  end

  def import
    @netsuite_donor = fetch_donor
    verify_is_donor
    create_donor
  end

  private

  def fetch_donor
    NetSuiteIntegration::Constituent.by_id(netsuite_id)
  rescue NetSuite::RecordNotFound
    record_for_error = Donor.new(external_id: netsuite_id)
    record_for_error.errors.add(:base, "Could not find NetSuite Constituent with NetSuite ID #{netsuite_id}")
    raise ActiveRecord::RecordInvalid, record_for_error
  end

  def verify_is_donor
    return if netsuite_donor.donor?

    record_for_error = Donor.new(external_id: netsuite_donor.netsuite_id)
    error_message = "NetSuite Constituent '#{netsuite_donor.name}' (NetSuite ID #{netsuite_id}) is not a donor!"
    record_for_error.errors.add(:base, error_message)
    raise ActiveRecord::RecordInvalid, record_for_error
  end

  def create_donor
    Donor.create! do |donor|
      donor.name = netsuite_donor.name
      donor.external_id = netsuite_donor.netsuite_id
      donor.external_type = netsuite_donor.type
      donor.email = netsuite_donor.email
      donor.primary_number = netsuite_donor.phone

      netsuite_address = netsuite_donor.address
      if netsuite_address
        # netsuite_address will be a hash with the proper address parts
        donor.addresses.build(netsuite_address)
      end
    end
  end
end

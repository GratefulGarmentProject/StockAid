module NetSuiteIntegration
  class OrganizationImporter
    attr_reader :netsuite_id, :netsuite_org

    def initialize(params)
      @netsuite_id = params.require(:external_id).to_i
    end

    def import
      @netsuite_org = fetch_organization
      verify_is_organization
      create_organization
    end

    private

    def fetch_organization
      NetSuiteIntegration::Constituent.by_id(netsuite_id)
    rescue NetSuite::RecordNotFound
      record_for_error = Organization.new(external_id: netsuite_id)
      record_for_error.errors.add(:base, "Could not find NetSuite Constituent with NetSuite ID #{netsuite_id}")
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    def verify_is_organization
      return if netsuite_org.organization?

      record_for_error = Organization.new(external_id: netsuite_org.netsuite_id)
      error_message = "NetSuite Constituent '#{netsuite_org.name}' (NetSuite ID #{netsuite_id}) is not an organization!"
      record_for_error.errors.add(:base, error_message)
      raise ActiveRecord::RecordInvalid, record_for_error
    end

    def create_organization
      Organization.create! do |organization|
        organization.name = netsuite_org.name
        organization.external_id = netsuite_org.netsuite_id
        organization.external_type = netsuite_org.type
        organization.email = netsuite_org.email
        organization.phone_number = netsuite_org.phone

        netsuite_address = netsuite_org.address
        if netsuite_address
          # netsuite_address will be a hash with the proper address parts
          organization.addresses.build(netsuite_address)
        end
      end
    end
  end
end

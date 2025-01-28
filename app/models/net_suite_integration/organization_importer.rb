module NetSuiteIntegration
  class OrganizationImporter
    attr_reader :netsuite_id, :netsuite_org, :program_ids

    def initialize(params)
      @netsuite_id = params.require(:external_id).to_i
      org_params = params.require(:organization).permit(program_ids: [])
      @program_ids = org_params[:program_ids]
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

    def create_organization # rubocop:disable Metrics/AbcSize
      Organization.transaction do
        Organization.create! do |organization|
          organization.name = netsuite_org.name
          organization.external_id = netsuite_org.netsuite_id
          organization.external_type = netsuite_org.type
          organization.email = netsuite_org.email
          organization.phone_number = netsuite_org.phone
          organization.program_ids = program_ids

          netsuite_address = netsuite_org.address
          if netsuite_address
            # netsuite_address will be a hash with the proper address parts
            organization.addresses.build(netsuite_address)
          end

          county = fetch_county
          organization.organization_county = county if county
        end
      end
    end

    def fetch_county
      return nil if netsuite_org.county_id.blank?

      county = County.where(external_id: netsuite_org.county_id).first
      return county if county

      match = /\ACalifornia : (.*) County\z/.match(netsuite_org.county_name)

      return unless match
      County.create!(name: match[1], external_id: netsuite_org.county_id)
    end
  end
end

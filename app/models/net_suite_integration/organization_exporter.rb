module NetSuiteIntegration
  class OrganizationExporter
    attr_reader :organization, :customer_record
    private(*delegate(:netsuite_type, :netsuite_profile, :netsuite_classification, :netsuite_address,
                      :grateful_garment_subsidiary,
                      to: "NetSuiteIntegration::Constituent"))

    def initialize(organization)
      @organization = organization
    end

    def self.create_and_export(params)
      Organization.transaction do
        organization = Organization.create!(Organization.permitted_organization_params(params))
        new(organization).export if params[:save_and_export_organization] == "true"
        organization
      end
    end

    def export
      initialize_customer_record
      assign_native_netsuite_attributes
      assign_custom_netsuite_attributes
      assign_netsuite_address
      export_to_netsuite
      customer_record
    end

    private

    def initialize_customer_record
      @customer_record = NetSuite::Records::Customer.new
      @customer_record.is_person = false
    end

    def assign_native_netsuite_attributes
      customer_record.company_name = organization.name
      customer_record.subsidiary = grateful_garment_subsidiary
      customer_record.email = organization.email
      customer_record.phone = organization.phone_number
    end

    def assign_custom_netsuite_attributes
      customer_record.custom_field_list.custentity_npo_constituent_type = netsuite_type(organization.external_type)
      customer_record.custom_field_list.custentity_npo_constituent_profile = [netsuite_profile("Agency")]
      customer_record.custom_field_list.custentity_npo_txn_classification = [netsuite_classification("Agency")]
    end

    def assign_netsuite_address
      address = netsuite_address(organization.addresses.first)
      customer_record.addressbook_list.addressbook << address if address
    end

    def export_to_netsuite
      raise "Failed to export organization!" unless customer_record.add

      organization.external_id = customer_record.internal_id.to_i
      organization.save!
    end
  end
end

class NetSuiteIntegration::OrganizationExporter
  attr_reader :organization, :customer_record
  private *delegate(:netsuite_type, :netsuite_profile, :netsuite_classification, :netsuite_address,
                    to: "NetSuiteIntegration::Constituent")

  def initialize(organization)
    @organization = organization
  end

  def self.create_and_export(params)
    Organization.transaction do
      org_params = params.require(:organization)

      org_params[:addresses_attributes].select! do |_, h|
        h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? }
      end

      organization = Organization.create!(
        org_params.permit(:name, :phone_number, :email, :external_id, :external_type,
                          addresses_attributes: %i[address street_address city state zip id])
      )

      if params[:save_and_export_organization] == "true"
        new(organization).export
      end

      organization
    end
  end

  def export
    initialize_customer_record
    assign_native_netsuite_attributes
    assign_custom_netsuite_attributes
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

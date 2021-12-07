module NetSuiteIntegration
  class DonorExporter
    attr_reader :donor, :customer_record
    private(*delegate(:netsuite_type, :netsuite_profile, :netsuite_classification, :netsuite_address,
                      :grateful_garment_subsidiary,
                      to: "NetSuiteIntegration::Constituent"))

    # These types will be considered a person when exporting to NetSuite
    PERSON_NETSUITE_TYPES = [
      "Individual",
      "Household",
      "Board of Director"
    ].freeze

    def initialize(donor)
      @donor = donor
    end

    def self.person_type?(external_type)
      PERSON_NETSUITE_TYPES.include?(external_type)
    end

    def self.find_or_create_and_export(params)
      raise "Missing selected_donor param!" if params[:selected_donor].blank?
      return Donor.find(params[:selected_donor]) if params[:selected_donor] != "new"
      create_and_export(params)
    end

    def self.create_and_export(params)
      Donor.transaction do
        donor = Donor.create!(Donor.permitted_donor_params(params))
        new(donor).export_later if params[:save_and_export_donor] == "true"
        donor
      end
    end

    def export_later
      NetSuiteIntegration.export_queued(donor)
      ExportDonorJob.perform_later(donor.id)
    end

    def export
      initialize_customer_record
      assign_name_attributes
      assign_native_netsuite_attributes
      assign_custom_netsuite_attributes
      assign_netsuite_address
      export_to_netsuite
      customer_record
    end

    private

    def initialize_customer_record
      @customer_record = NetSuite::Records::Customer.new
    end

    def person?
      NetSuiteIntegration::DonorExporter.person_type?(donor.external_type)
    end

    def assign_name_attributes
      customer_record.is_person = person?

      if person?
        name_parts = donor.name.split(" ", 3)
        customer_record.first_name = name_parts.first
        customer_record.middle_name = name_parts[1] if name_parts.size > 2
        customer_record.last_name = name_parts.last if name_parts.size > 1
      else
        customer_record.company_name = donor.name
      end
    end

    def assign_native_netsuite_attributes
      customer_record.subsidiary = grateful_garment_subsidiary
      customer_record.email = donor.email
      customer_record.phone = donor.primary_number
    end

    def assign_custom_netsuite_attributes
      customer_record.custom_field_list.custentity_npo_constituent_type = netsuite_type(donor.external_type)
      customer_record.custom_field_list.custentity_npo_constituent_profile = [netsuite_profile("Donor")]
      customer_record.custom_field_list.custentity_npo_txn_classification = [netsuite_classification("Donor")]
    end

    def assign_netsuite_address
      address = netsuite_address(donor.addresses.first)
      customer_record.addressbook_list.addressbook << address if address
    end

    def export_to_netsuite
      raise NetSuiteIntegration::ExportError.new("Failed to export donor!", customer_record) unless customer_record.add

      donor.external_id = customer_record.internal_id.to_i
      donor.save!
    end
  end
end

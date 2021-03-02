module Users
  module DonorManipulator
    extend ActiveSupport::Concern

    def can_create_donors?
      super_admin?
    end

    def can_update_donors?
      super_admin?
    end

    def can_view_donors?
      super_admin?
    end

    def can_delete_and_restore_donors?
      super_admin?
    end

    def create_donor(params, via: :manual)
      raise PermissionError unless can_create_donors?

      case via
      when :netsuite_import
        NetSuiteIntegration::DonorImporter.new(params).import
      when :manual
        NetSuiteIntegration::DonorExporter.create_and_export(params)
      else
        raise "Invalid Donor creation method: #{via}"
      end
    end

    def update_donor(params)
      raise PermissionError unless can_update_donors?
      donor = Donor.includes(:addresses).find(params[:id])
      donor.update! Donor.permitted_donor_params(params)
    end
  end
end

module Users
  module DonationManipulator
    extend ActiveSupport::Concern

    def can_view_donations?
      super_admin?
    end

    def can_create_donations?
      super_admin?
    end

    def can_delete_and_restore_donations?
      super_admin?
    end

    def create_donation(params)
      transaction do
        raise PermissionError unless can_create_donations?
        donor = NetSuiteIntegration::DonorExporter.find_or_create_and_export(params)
        Donation.create_donation!(self, donor, params)
      end
    end

    def update_donation(params)
      transaction do
        raise PermissionError unless can_create_donations?
        donation = Donation.active.find(params[:id])
        raise PermissionError unless can_view_donation?(donation)
        donation.update_donation!(params)
      end
    end

    def can_view_donation?(_donation)
      super_admin?
    end

    def donations_with_access
      if super_admin?
        @donations_with_access ||= Donation.active.includes(:donor, :donation_details, :user).order(id: :desc)
      else
        []
      end
    end
  end
end

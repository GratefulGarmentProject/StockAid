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

    def create_donor(params)
      raise PermissionError unless can_create_donors?
      Donor.create! Donor.permitted_donor_params(params)
    end

    def update_donor(params)
      raise PermissionError unless can_update_donors?
      donor = Donor.includes(:addresses).find(params[:id])
      donor.update! Donor.permitted_donor_params(params)
    end
  end
end

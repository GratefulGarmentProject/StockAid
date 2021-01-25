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

    def can_close_donations?
      super_admin?
    end

    def create_donation(params)
      transaction do
        raise PermissionError unless can_create_donations?
        Donation.create_donation!(self, params)
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
  end
end

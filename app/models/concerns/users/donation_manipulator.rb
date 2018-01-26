module Users
  module DonationManipulator
    extend ActiveSupport::Concern

    def can_view_donations?
      super_admin?
    end

    def can_create_donations?
      super_admin?
    end

    def create_donation(params)
      transaction do
        raise PermissionError unless can_create_donations?
        Donation.create_donation!(self, params)
      end
    end

    def can_view_donation?(_donation)
      super_admin?
    end

    def donations_with_access
      if super_admin?
        @donations_with_access ||= Donation.includes(:donor, :donation_details, :user).order(id: :desc)
      else
        []
      end
    end
  end
end

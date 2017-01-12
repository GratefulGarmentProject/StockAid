module Users
  module DonationManipulator
    extend ActiveSupport::Concern

    def can_view_donations?
      super_admin?
    end
  end
end

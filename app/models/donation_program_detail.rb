class DonationProgramDetail < ApplicationRecord
  belongs_to :donation
  belongs_to :program

  validate :not_changing_after_closed

  private

  def not_changing_after_closed
    return unless donation.closed?
    errors.add(:base, "cannot change a closed donation!")
  end
end

class DonationProgramDetail < ApplicationRecord
  belongs_to :donation
  belongs_to :program

  validate :not_changing_after_closed

  # This should ONLY be called from Donation
  def soft_delete_closed
    @allow_change_after_closed = true
    self.value = 0
    save!
  ensure
    @allow_change_after_closed = false
  end

  private

  def not_changing_after_closed
    return if @allow_change_after_closed
    return unless donation.closed?
    errors.add(:base, "cannot change a closed donation!")
  end
end

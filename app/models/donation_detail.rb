class DonationDetail < ActiveRecord::Base
  belongs_to :donation
  belongs_to :item, -> { unscope(where: :deleted_at) }
  after_create :update_inventory
  attr_accessor :for_migration

  validates :quantity, :value, presence: true

  def total_value
    quantity * value
  end

  private

  def update_inventory
    return if for_migration

    item.mark_event(
      edit_amount: quantity,
      edit_method: "add",
      edit_reason: "donation",
      edit_source: "Donation ##{donation_id}"
    )

    item.save!
  end
end

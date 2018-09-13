class DropshipOrderDetail < ApplicationRecord
  belongs_to :dropship_order
  belongs_to :item, -> { unscope(where: :deleted_at) }

  # after_create :update_inventory

  def total_cost
    quantity * cost
  end

  private

  # def update_inventory
  #   return if for_migration

  #   item.mark_event(
  #     edit_amount: quantity,
  #     edit_method: "add",
  #     edit_reason: "donation",
  #     edit_source: "Donation ##{donation_id}"
  #   )

  #   item.save!
  # end
end

class PurchaseDetail < ApplicationRecord
  belongs_to :purchase
  belongs_to :item, -> { unscope(where: :deleted_at) }

  after_create :update_inventory

  validates :quantity, :cost, presence: true

  def line_cost
    quantity * cost
  end

  private

  def update_inventory
    item.mark_event(
      edit_amount: quantity,
      edit_method: "add",
      edit_reason: "purchase",
      edit_source: "Purchase ##{purchase_id}"
    )

    item.save!
  end
end

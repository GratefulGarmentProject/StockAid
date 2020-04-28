class PurchaseDetail < ApplicationRecord
  belongs_to :purchase, optional: true
  belongs_to :item, -> { unscope(where: :deleted_at) }

  before_validation :calculate_variance

  validates :quantity, :cost, :variance, presence: true

  def line_cost
    quantity * cost
  end

  def as_json
    attributes.merge(
      category_id: item.category_id,
      item_value: item.value # needed to calculate PPV on form, although it's really calculated in the back end
    )
  end

  def add_to_inventory
    item.mark_event(
      edit_amount: quantity,
      edit_method: "add",
      edit_reason: "purchase_completed_adjustment",
      edit_source: item_edit_source
    )
    item.save!
  end

  def subtract_from_inventory
    item.mark_event(
      edit_amount: quantity,
      edit_method: "subtract",
      edit_reason: "purchase_canceled_adjustment",
      edit_source: item_edit_source
    )
    item.save!
  end

  private

  def calculate_variance
    # IMPORTANT! Keep negative values
    self.variance = item.value - cost
  end

  def item_edit_source
    "Purchase PO ##{purchase.po} Line item ##{id}"
  end
end

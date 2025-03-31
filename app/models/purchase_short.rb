class PurchaseShort < ApplicationRecord
  belongs_to :purchase_detail

  validate :quantity_shorted_remaining, on: :create

  after_create :subtract_from_purchase_detail

  private

  def quantity_shorted_remaining
    remaining = purchase_detail.quantity - purchase_detail.total_quantity_received
    return if quantity_shorted <= remaining

    # Individual field errors won't show up on these views, they are shown on
    # the page as a whole, so use a base message that is understandable enough
    # with less context.
    errors.add(:quantity_shorted, "Cannot add a quantity shorted that is less than or equal to remaining quantity (attempted to add a short of
                                   #{quantity_shorted} with remaining quantity of #{remaining})")
  end

  def subtract_from_purchase_detail
    purchase_detail.update!(quantity: purchase_detail.quantity - quantity_shorted)
  end
end

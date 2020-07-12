class PurchaseDetail < ApplicationRecord
  attribute :quantity_remaining, :integer
  attribute :quantity_shipped, :integer

  belongs_to :purchase, optional: true
  belongs_to :item, -> { unscope(where: :deleted_at) }

  has_many :purchase_shipments, dependent: :restrict_with_exception

  accepts_nested_attributes_for(
    :purchase_shipments,
    allow_destroy: true,
    reject_if: :shipment_attributes_invalid
  )

  before_validation :calculate_variance

  validates :quantity, :cost, :variance, presence: true
  validates :quantity_remaining, numericality: { greater_than_or_equal_to: 0 }
  validate do
    quantity_shipped_less_than_quantity
  end

  def line_cost
    quantity * cost
  end

  def display_variance
    return "" unless variance.present? && item.value.present?
    (format "%.2f", variance) + " (from " +
      (format "%.2f", item.value) + ")"
  end

  def quantity_remaining
    return unless quantity
    quantity - quantity_shipped
  end

  def quantity_shipped
    purchase_shipments.sum(:quantity_received)
  end

  private

  def calculate_variance
    # IMPORTANT! Keep negative values
    self.variance = item.value - cost
  end

  def shipment_attributes_invalid(attributes)
    attributes["quantity_received"].blank? || attributes["quantity_received"].to_i < 1
  end

  def quantity_shipped_less_than_quantity
    qty_received = purchase_shipments.map(&:quantity_received).sum()
    return true if qty_received <= quantity
    msg = %{Attempting to create shipment resulting in total quantity recieved (#{qty_received})
            exceeding number of items ordered (#{quantity}).}
    self.errors[:purchase_shipment] << msg
  end
end

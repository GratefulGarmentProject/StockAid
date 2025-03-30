class PurchaseDetail < ApplicationRecord
  include ActiveSupport::NumberHelper

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

  alias_attribute :shipments, :purchase_shipments

  def line_cost
    return unless quantity
    quantity * cost
  end

  def display_variance
    "#{number_to_currency(variance || 0)} (from #{number_to_currency(item&.value || 0)})"
  end

  def quantity_remaining
    return unless quantity
    quantity - shipments_quantity_received
  end

  def shipments_quantity_received
    purchase_shipments.sum(:quantity_received)
  end

  def display_for_quantity
    return quantity unless purchase.show_shipments?
    "#{shipments_quantity_received} / #{quantity}"
  end

  def fully_received?
    total_quantity_received >= quantity
  end

  def editable_details?
    purchase.new_purchase? || new_record?
  end

  def show_shipments?
    !new_record? && purchase.show_shipments?
  end

  private

  def total_quantity_received
    purchase_shipments.map(&:quantity_received).sum
  end

  def calculate_variance
    # IMPORTANT! Keep negative values
    self.variance = cost - item.value
  end

  def shipment_attributes_invalid(attributes)
    attributes["quantity_received"].blank? || attributes["quantity_received"].to_i < 1
  end

  def quantity_shipped_less_than_quantity
    qty_received = total_quantity_received
    return true if qty_received <= quantity
    msg = %{Attempting to create shipment resulting in total quantity recieved (#{qty_received})
            exceeding number of items ordered (#{quantity}).}
    errors[:purchase_shipment] << msg
  end
end

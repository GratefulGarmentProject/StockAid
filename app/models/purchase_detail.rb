class PurchaseDetail < ApplicationRecord
  belongs_to :purchase, optional: true
  belongs_to :item, -> { unscope(where: :deleted_at) }
  has_many :purchase_shipments, dependent: :restrict_with_exception
  accepts_nested_attributes_for :purchase_shipments, allow_destroy: true

  before_validation :calculate_variance

  validates :quantity, :cost, :variance, presence: true

  def line_cost
    quantity * cost
  end

  private

  def calculate_variance
    # IMPORTANT! Keep negative values
    self.variance = item.value - cost
  end
end

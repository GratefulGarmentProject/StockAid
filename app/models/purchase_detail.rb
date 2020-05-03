class PurchaseDetail < ApplicationRecord
  belongs_to :purchase, optional: true
  belongs_to :item, -> { unscope(where: :deleted_at) }
  has_many :purchase_shipments, dependent: :restrict_with_exception
  accepts_nested_attributes_for :purchase_shipments

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

  private

  def calculate_variance
    # IMPORTANT! Keep negative values
    self.variance = item.value - cost
  end
end

class ItemProgramRatio < ApplicationRecord
  has_many :item_program_ratio_values

  validate :percentages_add_to_100

  private

  def percentages_add_to_100
    return if item_program_ratio_values.map(&:percentage).sum == BigDecimal.new("100.00")
    errors.add(:item_program_ratio_values, "must add up to 100 exactly")
  end
end

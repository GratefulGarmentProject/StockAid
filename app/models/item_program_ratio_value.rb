class ItemProgramRatioValue < ApplicationRecord
  belongs_to :item_program_ratio
  belongs_to :program

  validates :percentage, numericality: { greater_than_or_equal_to: 0 }
end

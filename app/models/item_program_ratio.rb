class ItemProgramRatio < ApplicationRecord
  has_many :items
  has_many :item_program_ratio_values, dependent: :destroy

  validate :percentages_add_to_100

  def program_percentage(program)
    @programs_by_id ||= item_program_ratio_values.index_by(&:program_id)
    value = @programs_by_id[program.id]

    if value
      value.percentage
    else
      BigDecimal.new("0")
    end
  end

  def update_program_ratios(ratios)
    item_program_ratio_values.clear

    Program.all.find_each do |program|
      value = BigDecimal.new(ratios[program.id.to_s])
      next if value == 0
      item_program_ratio_values.build(program: program, percentage: value)
    end
  end

  private

  def percentages_add_to_100
    return if item_program_ratio_values.map(&:percentage).sum == BigDecimal.new("100.00")
    errors.add(:item_program_ratio_values, "must add up to 100 exactly")
  end
end

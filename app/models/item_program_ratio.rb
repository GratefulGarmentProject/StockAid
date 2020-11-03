class ItemProgramRatio < ApplicationRecord
  has_many :items
  has_many :item_program_ratio_values, dependent: :destroy

  validate :percentages_add_to_100

  def self.to_json
    {}.tap do |result|
      ItemProgramRatio.find_each do |ratio|
        result[ratio.id] = {}.tap do |map|
          ratio.item_program_ratio_values.each do |value|
            map[value.program_id] = format("%g", value.percentage)
          end
        end
      end
    end.to_json
  end

  def ordered_items_with_category
    @ordered_items_with_category ||= items.includes(:category).order("categories.description", :description).to_a
  end

  def ordered_items_by_category
    @ordered_items_by_category ||= ordered_items_with_category.group_by(&:category)
  end

  def ordered_unapplied_items_by_category
    @ordered_unapplied_items_by_category ||=
      Item.where.not(id: items.pluck(:id)).includes(:category).order("categories.description", :description)
          .to_a.group_by(&:category)
  end

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

  def apply_to_new_items(items)
    return if items.blank?
    Item.where(id: items.keys).update_all(item_program_ratio_id: id) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def percentages_add_to_100
    return if item_program_ratio_values.map(&:percentage).sum == BigDecimal.new("100.00")
    errors.add(:item_program_ratio_values, "must add up to 100 exactly")
  end
end

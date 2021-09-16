class CountSheetDetail < ApplicationRecord
  belongs_to :count_sheet
  belongs_to :item

  def has_data? # rubocop:disable Naming/PredicateName
    return true if counts.present? && counts.any?(&:present?)
    final_count.present?
  end
end

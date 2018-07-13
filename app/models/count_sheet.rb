class CountSheet < ApplicationRecord
  belongs_to :inventory_reconciliation
  belongs_to :bin, optional: true
  has_many :count_sheet_details
  has_many :items, -> { order(:description) }, through: :count_sheet_details
  validate :final_counts_present_on_complete

  def columns
    [counter_names.size, *(count_sheet_details.map { |x| x.counts.size })].max
  end

  def update_sheet(params)
    raise PermissionError if complete
    columns = CountSheetColumn.parse(params)
    self.counter_names = columns.map(&:counter_name)
    self.complete = params[:complete].present?
    update_sheet_details(columns, params)
    save!
  end

  def create_missing_count_sheet_details
    return if complete

    transaction do
      return unless bin
      bin_items = bin.items.to_a
      new_items = bin_items - items.to_a

      new_items.each do |item|
        count_sheet_details.create! item: item, counts: Array.new(counter_names.size)
      end
    end
  end

  private

  def update_sheet_details(columns, params)
    count_sheet_details.each do |details|
      details.counts = columns.map { |c| c.count(details.id) }
      details.final_count = params[:final_counts][details.id.to_s]
      details.save!
    end
  end

  def final_counts_present_on_complete
    if complete && count_sheet_details.any? { |x| x.final_count.blank? }
      errors.add(:count_sheet_details, "must have final values on complete")
    end
  end
end

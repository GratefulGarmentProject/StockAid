class CountSheet < ApplicationRecord
  belongs_to :inventory_reconciliation
  belongs_to :bin, optional: true
  has_many :count_sheet_details
  has_many :items, -> { order(:description) }, through: :count_sheet_details

  def columns
    [counter_names.size, *(count_sheet_details.map { |x| x.counts.size })].max
  end

  def update_sheet(params)
    columns = CountSheetColumn.parse(params)
    self.counter_names = columns.map(&:counter_name)

    count_sheet_details.each do |details|
      details.counts = columns.map { |c| c.count(details.id) }
      details.save!
    end

    save!
  end
end

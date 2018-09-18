require "set"

class InventoryReconciliation < ApplicationRecord
  belongs_to :user
  has_many :reconciliation_notes, -> { includes(:user).order(created_at: :desc) }
  has_many :count_sheets, -> { includes(:bin, :count_sheet_details) }

  def count_sheet_for_show(params)
    if params[:id] == "misfits"
      find_or_create_misfits_count_sheet
    else
      count_sheets.includes(count_sheet_details: :item).find(params[:id])
    end
  end

  def find_or_create_misfits_count_sheet
    transaction do
      misfits = count_sheets.includes(count_sheet_details: :item).misfits.first
      return misfits if misfits
      count_sheets.create!(counter_names: Array.new(2))
    end
  end

  def create_missing_count_sheets
    transaction do
      bins = Bin.not_deleted.includes(:items).to_a
      new_bins = bins - count_sheets.map(&:bin)

      new_bins.each do |bin|
        next if bin.items.empty?
        create_count_sheet(bin)
      end
    end
  end

  def complete_reconciliation
    raise PermissionError if complete
    raise PermissionError unless deltas.ready_to_complete?
    deltas.each(&:reconcile)
    self.complete = true
    save!
  end

  def deltas
    @deltas ||= ReconciliationDeltas.new(self)
  end

  def full_title
    "#{title} - #{display_created_at}"
  end

  def display_created_at
    created_at.strftime("%b-%d-%Y")
  end

  def paper_trail_edit_source
    "Reconciliation ##{id}"
  end

  def updated_item_versions
    @updated_items ||=
      Item.paper_trail_version_class.includes(item: :category).where(edit_source: paper_trail_edit_source).to_a
  end

  private

  def create_count_sheet(bin)
    count_sheets.create! do |sheet|
      sheet.bin = bin
      sheet.counter_names = Array.new(2)

      bin.items.each do |item|
        sheet.count_sheet_details.build(item: item, counts: Array.new(2))
      end
    end
  end
end

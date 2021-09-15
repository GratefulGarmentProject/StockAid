require "set"

class InventoryReconciliation < ApplicationRecord
  belongs_to :user
  has_many :reconciliation_notes, -> { includes(:user).order(created_at: :desc) }
  has_many :count_sheets, -> { includes(:bin, :count_sheet_details) }
  has_many :reconciliation_program_details, autosave: true

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
    ignored_ids = Set.new(ignored_bin_ids)

    transaction do
      bins = Bin.not_deleted.includes(:items).to_a
      new_bins = bins - count_sheets.map(&:bin)

      new_bins.each do |bin|
        next if bin.items.empty?
        next if ignored_ids.include?(bin.id)
        create_count_sheet(bin)
      end
    end
  end

  def delete_count_sheet(sheet_id)
    raise PermissionError if complete
    sheet = count_sheets.includes(:count_sheet_details).find(sheet_id)
    raise PermissionError if sheet.complete
    bin_id = sheet.bin_id
    sheet.count_sheet_details.each(&:destroy!)
    sheet.destroy!
    ignored_bin_ids << bin_id unless ignored_bin_ids.include?(bin_id)
    save!
  end

  def complete_reconciliation
    raise PermissionError if complete
    raise PermissionError unless deltas.ready_to_complete?
    deltas.each(&:reconcile)
    self.complete = true
    self.completed_at = Time.zone.now
    save!
    create_values_for_programs
  end

  def create_values_for_programs
    program_values = Hash.new { |h, k| h[k] = 0.0 }

    deltas.each do |delta|
      ratios = delta.item.program_ratio_split_for(delta.item.programs)

      ratios.each do |program, ratio|
        program_values[program] += delta.total_value_changed * ratio
      end
    end

    program_values.each do |program, value|
      reconciliation_program_details.create!(program: program, value: value)
    end
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
      Item.unscoped do
        Item.paper_trail_version_class.includes(item: :category).where(edit_source: paper_trail_edit_source).to_a
      end
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

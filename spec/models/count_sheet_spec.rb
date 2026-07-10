require "rails_helper"

RSpec.describe CountSheet, type: :model do
  let(:reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }
  let(:count_sheet) { count_sheets(:flip_flop_count_sheet) }

  describe "#bin_label" do
    it "returns 'Misfits' for a sheet with no bin" do
      misfits_sheet = reconciliation.count_sheets.create!(counter_names: [])
      expect(misfits_sheet.bin_label).to eq("Misfits")
    end

    it "returns the bin label for a sheet with a bin" do
      expect(count_sheet.bin_label).to eq(bins(:flip_flop_bin).label)
    end
  end

  describe "#num_columns" do
    it "returns the max column count" do
      expect(count_sheet.num_columns).to be_a(Integer)
    end
  end

  describe "#has_data?" do
    it "returns true when counter_names has present entries" do
      count_sheet.counter_names = ["Alice", ""]
      expect(count_sheet.has_data?).to eq(true)
    end

    it "returns false when all counter_names are blank and no details have data" do
      count_sheet.counter_names = ["", nil]
      expect(count_sheet.has_data?).to eq(false)
    end
  end

  describe "#mark_incomplete" do
    it "marks a complete count sheet as incomplete" do
      count_sheet.update_column(:complete, true)
      params = ActionController::Parameters.new(incomplete: "true")
      count_sheet.update_sheet(params)
      expect(count_sheet.reload.complete).to eq(false)
    end
  end
end

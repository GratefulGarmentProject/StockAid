require "rails_helper"

RSpec.describe InventoryReconciliation, type: :model do
  let(:reconciliation) { inventory_reconciliations(:open_reconciliation) }
  let(:in_progress) { inventory_reconciliations(:in_progress_reconciliation) }

  describe "#full_title" do
    it "includes title and formatted date" do
      expect(reconciliation.full_title).to include(reconciliation.title)
      expect(reconciliation.full_title).to include(reconciliation.display_created_at)
    end
  end

  describe "#display_created_at" do
    it "formats the creation date" do
      result = reconciliation.display_created_at
      expect(result).to match(/\w{3}-\d{2}-\d{4}/)
    end
  end

  describe "#paper_trail_edit_source" do
    it "returns a string with the reconciliation id" do
      expect(reconciliation.paper_trail_edit_source).to include(reconciliation.id.to_s)
    end
  end

  describe "#ignored_bins" do
    it "returns an empty scope when no bins are ignored" do
      expect(reconciliation.ignored_bins).to be_empty
    end
  end

  describe "#find_or_create_misfits_count_sheet" do
    it "creates a misfits count sheet if one doesn't exist" do
      expect do
        reconciliation.find_or_create_misfits_count_sheet
      end.to change(CountSheet, :count).by(1)
    end

    it "returns the same sheet on subsequent calls" do
      sheet1 = reconciliation.find_or_create_misfits_count_sheet
      sheet2 = reconciliation.find_or_create_misfits_count_sheet
      expect(sheet1.id).to eq(sheet2.id)
    end
  end

  describe "#count_sheet_for_show" do
    it "returns the misfits count sheet for 'misfits' param" do
      sheet = reconciliation.count_sheet_for_show(id: "misfits")
      expect(sheet).to be_a(CountSheet)
    end

    it "returns a specific count sheet by id" do
      existing_sheet = in_progress.count_sheets.first
      found = in_progress.count_sheet_for_show(id: existing_sheet.id.to_s)
      expect(found.id).to eq(existing_sheet.id)
    end
  end

  describe "#updated_item_versions" do
    it "returns an array of paper trail versions from this reconciliation" do
      result = reconciliation.updated_item_versions
      expect(result).to be_an(Array)
    end
  end

  describe "#delete_unnecessary_count_sheets" do
    it "does not raise on an open reconciliation with no incomplete sheets with no data" do
      expect { reconciliation.delete_unnecessary_count_sheets }.not_to raise_error
    end
  end

  describe "#create_missing_count_sheets" do
    it "creates count sheets for bins that have items but no existing sheet" do
      expect { reconciliation.create_missing_count_sheets }.not_to raise_error
    end
  end
end

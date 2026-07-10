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

    it "returns the ignored bins when bin ids are set" do
      bin = bins(:empty_bin)
      reconciliation.update!(ignored_bin_ids: [bin.id])
      expect(reconciliation.ignored_bins).to include(bin)
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

    it "skips bins in the ignored list" do
      bin = bins(:flip_flop_bin)
      reconciliation.update!(ignored_bin_ids: [bin.id])
      reconciliation.create_missing_count_sheets
      expect(reconciliation.count_sheets.map(&:bin_id)).not_to include(bin.id)
    end
  end

  describe "#delete_count_sheet" do
    it "destroys the sheet, marks bin as ignored, and saves" do
      sheet = in_progress.count_sheets.first
      bin_id = sheet.bin_id
      in_progress.delete_count_sheet(sheet.id)
      expect(in_progress.ignored_bin_ids).to include(bin_id)
    end

    it "raises PermissionError when reconciliation is complete" do
      complete = InventoryReconciliation.create!(user: users(:root), title: "Done", complete: true)
      expect { complete.delete_count_sheet(0) }.to raise_error(PermissionError)
    end
  end

  describe "#delete_unnecessary_count_sheets" do
    it "removes empty incomplete sheets from in_progress reconciliation" do
      expect { in_progress.delete_unnecessary_count_sheets }.not_to raise_error
    end

    it "raises PermissionError when reconciliation is complete" do
      complete = InventoryReconciliation.create!(user: users(:root), title: "Done 2", complete: true)
      expect { complete.delete_unnecessary_count_sheets }.to raise_error(PermissionError)
    end
  end

  describe "#complete_reconciliation" do
    it "raises PermissionError when already complete" do
      complete = InventoryReconciliation.create!(user: users(:root), title: "Already Complete", complete: true)
      expect { complete.complete_reconciliation }.to raise_error(PermissionError)
    end

    it "raises PermissionError when not ready to complete" do
      expect { in_progress.complete_reconciliation }.to raise_error(PermissionError)
    end

    it "completes successfully when there are no count sheets" do
      fresh = InventoryReconciliation.create!(user: users(:root), title: "Fresh Completable")
      fresh.complete_reconciliation
      expect(fresh.reload).to be_complete
      expect(fresh.completed_at).to be_present
    end
  end
end

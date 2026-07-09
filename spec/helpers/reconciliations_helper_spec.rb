require "rails_helper"

RSpec.describe ReconciliationsHelper, type: :helper do
  let(:reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }

  describe "#reconciliation_delta_table_row" do
    let(:delta_without_link) do
      double(
        warning_text: "No count sheets",
        warning_count_sheet_id: nil,
        row_css_class: "danger"
      )
    end

    let(:delta_with_link) do
      double(
        warning_text: "Uncounted bins",
        warning_count_sheet_id: 99,
        row_css_class: "warning",
        reconciliation: inventory_reconciliations(:in_progress_reconciliation)
      )
    end

    it "renders a tr tag with tooltip data attributes" do
      result = helper.reconciliation_delta_table_row(delta_without_link) { "content" }
      expect(result).to include("<tr")
      expect(result).to include("tooltip")
      expect(result).to include("No count sheets")
    end

    it "includes an href when warning_count_sheet_id is present" do
      result = helper.reconciliation_delta_table_row(delta_with_link) { "content" }
      expect(result).to include("href")
    end
  end

  describe "#changed_amount_icon" do
    let(:positive_delta) { double(changed_amount?: true, changed_amount: 5) }
    let(:negative_delta) { double(changed_amount?: true, changed_amount: -3) }
    let(:unchanged_delta) { double(changed_amount?: false) }

    it "returns an up arrow icon for positive changes" do
      result = helper.changed_amount_icon(positive_delta)
      expect(result).to include("triangle-top")
    end

    it "returns a down arrow icon for negative changes" do
      result = helper.changed_amount_icon(negative_delta)
      expect(result).to include("triangle-bottom")
    end

    it "returns nil for no change" do
      expect(helper.changed_amount_icon(unchanged_delta)).to be_nil
    end
  end
end

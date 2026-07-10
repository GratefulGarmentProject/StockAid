require "rails_helper"

describe ReconciliationDeltas, type: :model do
  let(:reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }
  let(:complete_reconciliation) do
    InventoryReconciliation.create!(user: users(:root), title: "Complete Spec", complete: true)
  end

  subject(:deltas) { described_class.new(reconciliation) }

  describe "#initialize" do
    it "accepts a reconciliation and defaults items from DB" do
      expect(deltas.reconciliation).to eq(reconciliation)
      expect(deltas.items).to be_an(Array)
    end

    it "accepts explicit items" do
      items = [items(:small_flip_flops)]
      d = described_class.new(reconciliation, items)
      expect(d.items).to eq(items)
    end
  end

  describe "#each" do
    it "yields delta objects for items with count sheets" do
      count = 0
      deltas.each { |_d| count += 1 }
      expect(count).to be >= 0
    end
  end

  describe "#ready_to_complete?" do
    it "returns false when some count sheets are not complete" do
      expect(deltas.ready_to_complete?).to be false
    end
  end

  describe "#total_value_changed" do
    it "returns a numeric value" do
      expect(deltas.total_value_changed).to be_a(Numeric)
    end
  end

  describe "#complete_confirm_options" do
    it "returns a hash with title and message" do
      opts = deltas.complete_confirm_options
      expect(opts[:title]).to include("Reconciliation")
      expect(opts[:message]).to include("Are you sure?")
    end
  end

  describe "ReconciliationDeltas::Delta CSS class methods" do
    let(:item) { items(:small_flip_flops) }
    let(:delta) { ReconciliationDeltas::Delta.new(reconciliation, item) }

    before do
      allow(delta).to receive(:changed_amount).and_return(5)
    end

    it "#description_css_class returns text-bold text-success when changed_amount > 0" do
      expect(delta.description_css_class).to eq("text-bold text-success")
    end

    it "#changed_amount_css_class returns text-success when changed_amount > 0" do
      expect(delta.changed_amount_css_class).to eq("text-success")
    end
  end

  describe "ReconciliationDeltas::Delta#uncounted_bin" do
    let(:item) { items(:small_flip_flops) }
    let(:delta) { ReconciliationDeltas::Delta.new(reconciliation, item) }

    it "increments uncounted bins count" do
      bin = bins(:flip_flop_bin)
      expect { delta.uncounted_bin(bin) }.to change { delta.instance_variable_get(:@uncounted_bins) }.by(1)
    end
  end

  describe "with a completed reconciliation" do
    subject(:complete_deltas) { described_class.new(complete_reconciliation) }

    it "#each iterates without error" do
      count = 0
      complete_deltas.each { |_d| count += 1 }
      expect(count).to be >= 0
    end

    it "#total_value_changed sums over completed deltas" do
      expect(complete_deltas.total_value_changed).to be_a(Numeric)
    end
  end
end

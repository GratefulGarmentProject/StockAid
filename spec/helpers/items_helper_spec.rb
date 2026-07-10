require "rails_helper"

RSpec.describe ItemsHelper, type: :helper do
  describe "#item_history_info" do
    context "with a 'create' event version with a value change but no current_quantity change" do
      let(:version) { instance_double(PaperTrail::Version, event: "create", edit_source: nil, edit_amount: nil, edit_method: nil, edit_reason: nil, changeset: changeset) }

      let(:changeset) do
        {
          "description" => [nil, "An item"],
          "category_id" => [nil, 42],
          "value" => [nil, 100.00],
          "sky" => [nil, 123456]
        }
      end

      it "returns a 0 amount result" do
        expect(helper.item_history_info(version)).to eq("Created with 0 items.")
      end
    end

    context "with an 'update' event version with a current_quantity change" do
      let(:version) do
        instance_double(
          PaperTrail::Version,
          event: "update",
          edit_source: "spec",
          edit_amount: 5,
          edit_method: "add",
          edit_reason: "adjustment",
          changeset: { "current_quantity" => [10, 15] }
        )
      end

      it "returns an adjustment result" do
        result = helper.item_history_info(version)
        expect(result).to be_a(String)
        expect(result).to include("15")
      end
    end

    context "with a bulk_pricing_change edit_reason" do
      let(:version) do
        instance_double(
          PaperTrail::Version,
          event: "update",
          edit_source: nil,
          edit_amount: nil,
          edit_method: nil,
          edit_reason: "bulk_pricing_change",
          changeset: { "value" => [10.0, 12.5] }
        )
      end

      it "returns a bulk pricing change result" do
        result = helper.item_history_info(version)
        expect(result).to include("Bulk pricing change")
      end
    end

    context "with no recognized changeset" do
      let(:version) do
        instance_double(
          PaperTrail::Version,
          id: 999,
          event: "update",
          edit_source: nil,
          edit_amount: nil,
          edit_method: nil,
          edit_reason: nil,
          changeset: { "description" => %w[old new] }
        )
      end

      it "raises an error" do
        expect { helper.item_history_info(version) }.to raise_error(RuntimeError, /Version history info cannot be determined/)
      end
    end
  end
end

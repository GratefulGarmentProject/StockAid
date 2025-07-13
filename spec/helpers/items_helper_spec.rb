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
  end
end

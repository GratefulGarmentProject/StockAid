require "rails_helper"

describe InventoryReconciliationsController, type: :controller do
  let(:open_reconciliation) { inventory_reconciliations(:open_reconciliation) }
  let(:root_user) { users(:root) }
  let(:flip_flops_category) { categories(:flip_flops) }

  describe "POST comment" do
    it "allows posting a comment" do
      signed_in_user :root

      post :comment, params: {
        id: open_reconciliation.id.to_s,
        content: "This is the content of the comment"
      }

      note = open_reconciliation.reload.reconciliation_notes.first
      expect(note.content).to eq("This is the content of the comment")
      expect(note.user).to eq(root_user)
    end
  end
end

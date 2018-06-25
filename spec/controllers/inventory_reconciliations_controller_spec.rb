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

    it "redirects to the reconciliation after" do
      signed_in_user :root

      response = post :comment, params: {
        id: open_reconciliation.id.to_s,
        content: "This is the content of the comment"
      }

      expect(response).to redirect_to(inventory_reconciliation_path(open_reconciliation))
    end

    it "redirects to a specified category in the reconciliation after" do
      signed_in_user :root

      response = post :comment, params: {
        id: open_reconciliation.id.to_s,
        content: "This is the content of the comment",
        category_id: flip_flops_category.id.to_s
      }

      expect(response).to redirect_to(inventory_reconciliation_path(open_reconciliation, category_id: flip_flops_category.id))
    end
  end
end

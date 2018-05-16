require "rails_helper"

describe BinsController, type: :controller do
  let(:empty_bin) { bins(:empty_bin) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }

  describe "GET edit" do
    render_views

    it "shows the delete button for an empty bin" do
      signed_in_user :root
      get :edit, params: { id: empty_bin.id.to_s }
      expect(response.body).to have_selector("a", text: "Delete")
    end

    it "doesn't show the delete button for a non-empty bin" do
      signed_in_user :root
      get :edit, params: { id: flip_flop_bin.id.to_s }
      expect(response.body).to_not have_selector("a", text: "Delete")
    end
  end

  describe "DELETE destroy" do
    it "allows deleting an empty bin" do
      signed_in_user :root
      delete :destroy, params: { id: empty_bin.id.to_s }
      expect { empty_bin.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "prevents deleting a non-empty bin" do
      signed_in_user :root

      expect do
        delete :destroy, params: { id: flip_flop_bin.id.to_s }
      end.to raise_error(PermissionError, /Cannot delete non-empty bin/)

      expect { flip_flop_bin.reload }.to_not raise_error
    end
  end
end

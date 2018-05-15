require "rails_helper"

describe BinsController, type: :controller do
  let(:empty_bin) { bins(:empty_bin) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }

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
      end.to raise_error

      expect { flip_flop_bin.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

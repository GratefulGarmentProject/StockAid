require "rails_helper"

RSpec.describe PurchaseShortsController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail) }

  before { sign_in super_admin }

  describe "#create" do
    it "returns JSON with rendered partial content" do
      post purchase_shorts_path, params: {
        purchase_detail_id: purchase_detail.id,
        purchase_detail_index: "0",
        purchase_short_index: "0"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("content")
    end
  end

  describe "#destroy" do
    let!(:purchase_short) do
      purchase_detail.purchase_shorts.create!(quantity_shorted: 2)
    end

    it "destroys the purchase short and renders JS" do
      expect do
        delete purchase_short_path(purchase_short, format: :js)
      end.to change(PurchaseShort, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end

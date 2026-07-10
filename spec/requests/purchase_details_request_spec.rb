require "rails_helper"

RSpec.describe PurchaseDetailsController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:purchase) { purchases(:new_purchase_with_details) }
  let!(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail) }

  before { sign_in super_admin }

  describe "#create" do
    it "returns JSON with rendered partial content" do
      post purchase_details_path, params: {
        purchase_id: purchase.id,
        purchase_detail_index: "0"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("content")
    end
  end

  describe "#destroy" do
    it "destroys the purchase detail and renders JS" do
      expect do
        delete purchase_detail_path(purchase_detail, format: :js)
      end.to change(PurchaseDetail, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end

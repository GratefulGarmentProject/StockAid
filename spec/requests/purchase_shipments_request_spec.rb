require "rails_helper"

RSpec.describe PurchaseShipmentsController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail) }
  let!(:purchase_shipment) { purchase_shipments(:small_flip_flops_partial_shipment_one) }

  before { sign_in super_admin }

  describe "#create" do
    it "returns JSON with rendered partial content" do
      post purchase_shipments_path, params: {
        purchase_detail_id: purchase_detail.id,
        purchase_detail_index: "0",
        purchase_shipment_index: "0"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("content")
    end
  end

  describe "#destroy" do
    it "destroys the purchase shipment and renders JS" do
      expect do
        delete purchase_shipment_path(purchase_shipment, format: :js)
      end.to change(PurchaseShipment, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end

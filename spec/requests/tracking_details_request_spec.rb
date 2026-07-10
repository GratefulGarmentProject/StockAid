require "rails_helper"

RSpec.describe TrackingDetailsController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:order) { orders(:open_order) }

  before { sign_in super_admin }

  describe "#update" do
    let!(:tracking_detail) do
      order.tracking_details.create!(shipping_carrier: "FedEx", tracking_number: "UPDATEME123")
    end

    it "updates the tracking detail and redirects to the order edit page" do
      patch tracking_detail_path(tracking_detail), params: { status: "delivered" }
      expect(response).to redirect_to(edit_order_path(order))
      expect(tracking_detail.reload.delivery_date).to be_present
    end

    it "updates without a status and redirects" do
      patch tracking_detail_path(tracking_detail), params: {}
      expect(response).to redirect_to(edit_order_path(order))
    end
  end

  describe "#destroy" do
    let!(:tracking_detail) do
      order.tracking_details.create!(shipping_carrier: "USPS", tracking_number: "DELETEME456")
    end

    it "destroys the tracking detail and redirects to the order edit page" do
      expect do
        delete tracking_detail_path(tracking_detail)
      end.to change(TrackingDetail, :count).by(-1)
      expect(response).to redirect_to(edit_order_path(order))
      expect(flash[:success]).to include("DELETEME456")
    end
  end
end

require "rails_helper"

RSpec.describe PurchasesController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:vendor) { vendors(:guinan) }

  describe "#index" do
    it "should retrieve the purchases list page" do
      sign_in super_admin
      get purchases_path
      expect(response).to have_http_status :ok
    end
  end

  describe "#create" do
    let!(:item1) { items(:small_flip_flops) }
    let!(:item2) { items(:medium_flip_flops) }

    let(:valid_parameters) do
      {
        purchase: {
          vendor_id: vendor.id,
          po: "123456aaaa",
          purchase_date: 1.day.ago,
          tax: "8.95",
          shipping_cost: "7.99",
          purchase_details_attributes: [
            {
              id: "",
              item_id: item1.id,
              quantity: "12",
              cost: "2",
              line_cost: "24"
            },
            {
              id: "",
              item_id: item2.id,
              quantity: "7",
              cost: "0.1",
              line_cost: "0.7"
            }
          ]
        }
      }
    end

    it "should create a new purchase, updating the purchase count" do
      sign_in super_admin
      post purchases_path, params: valid_parameters
      new_purchase = Purchase.find_by(po: "123456aaaa")
      aggregate_failures do
        expect(response).to have_http_status :found
        expect(response).to redirect_to purchases_path
        expect(new_purchase).to be_present
        expect(new_purchase.purchase_details.count).to eq(2), new_purchase.purchase_details.inspect
      end
    end
  end

  describe "#update" do
    let!(:purchase) do
      purchases(:new_purchase_with_details)
    end
    let!(:new_shipping_cost) { 8.25 }
    let!(:new_quantity) { 10 }

    let(:valid_parameters) do
      {
        purchase: {
          id: purchase.id,
          shipping_cost: new_shipping_cost,
          purchase_details_attributes: [
            {
              id: purchase.purchase_details.first.id,
              item_id: purchase.purchase_details.first.item_id,
              quantity: new_quantity,
              cost: purchase.purchase_details.first.cost,
              line_cost: new_quantity * purchase.purchase_details.first.cost
            },
            {
              id: purchase.purchase_details.last.id,
              item_id: purchase.purchase_details.last.item_id,
              quantity: purchase.purchase_details.last.quantity,
              cost: purchase.purchase_details.last.cost,
              line_cost: purchase.purchase_details.last.quantity * purchase.purchase_details.last.cost
            }
          ]
        }
      }
    end

    it "should update the purchase properly" do
      saved_shipping_cost = purchase.shipping_cost
      saved_quantity = purchase.purchase_details.first.quantity
      sign_in super_admin
      patch purchase_path(purchase), params: valid_parameters
      purchase.reload
      aggregate_failures do
        expect(response).to have_http_status :found
        expect(response).to redirect_to purchases_path
        expect(purchase.shipping_cost).not_to eq(saved_shipping_cost)
        expect(purchase.shipping_cost).to eq(new_shipping_cost)
        expect(purchase.purchase_details.first.quantity).not_to eq(saved_quantity)
        expect(purchase.purchase_details.first.quantity).to eq(new_quantity)
      end
    end

    context "adding a purchase_shipment" do
      let(:valid_parameters) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase.purchase_details.first.id,
                purchase_shipments_attributes: [
                  {
                    quantity_received: 2,
                    received_at: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates a new partial purchase shipment" do
        sign_in super_admin
        patch purchase_path(purchase), params: valid_parameters
        purchase.reload
        aggregate_failures do
          expect(response).to have_http_status :found
          expect(response).to redirect_to purchases_path
          expect(purchase.purchase_details.first.purchase_shipments.count).to eq(1)
        end
      end
    end
  end
end

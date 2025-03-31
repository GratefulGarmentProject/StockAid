require "rails_helper"

RSpec.describe PurchasesController, type: :request do
  let!(:super_admin) { users(:root) }
  let!(:vendor) { vendors(:guinan) }

  before do
    sign_in super_admin
  end

  describe "#index" do
    it "should retrieve the purchases list page" do
      get purchases_path
      expect(response).to have_http_status :ok
    end
  end

  describe "#create" do
    let!(:item1) { items(:small_flip_flops) }
    let!(:item2) { items(:medium_flip_flops) }
    let!(:vendor_po_number) { Time.current.to_i }

    let(:valid_parameters) do
      {
        save: "save",
        purchase: {
          vendor_id: vendor.id,
          vendor_po_number: vendor_po_number,
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
      post purchases_path, params: valid_parameters
      new_purchase = Purchase.find_by(vendor_po_number: vendor_po_number)
      aggregate_failures do
        expect(response).to have_http_status :found
        expect(response).to redirect_to edit_purchase_path(new_purchase)
        expect(new_purchase).to be_present
        expect(new_purchase.purchase_details.count).to eq(2), new_purchase.purchase_details.inspect
      end
    end
  end

  describe "#update" do
    let!(:purchase) { purchases(:new_purchase_with_details) }
    let!(:new_shipping_cost) { 8.25 }
    let!(:new_quantity) { 10 }

    let(:valid_parameters) do
      {
        save: "save",
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
      patch purchase_path(purchase), params: valid_parameters
      purchase.reload
      aggregate_failures do
        expect(response).to have_http_status :found
        expect(response).to redirect_to edit_purchase_path(purchase)
        expect(purchase.shipping_cost).not_to eq(saved_shipping_cost)
        expect(purchase.shipping_cost).to eq(new_shipping_cost)
        expect(purchase.purchase_details.first.quantity).not_to eq(saved_quantity)
        expect(purchase.purchase_details.first.quantity).to eq(new_quantity)
      end
    end

    describe "remove a purchase detail" do
      let(:valid_parameters) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [{
              id: purchase.purchase_details.first.id,
              _destroy: true
            }]
          }
        }
      end

      it "removes the purchase detail" do
        aggregate_failures do
          expect { patch purchase_path(purchase), params: valid_parameters }.to(
            change { purchase.reload.purchase_details.count }.by(-1)
          )
        end
      end
    end

    describe "adding a purchase_shipment" do
      let(:valid_parameters) do
        {
          save: "save",
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase.purchase_details.first.id,
                purchase_shipments_attributes: [
                  {
                    quantity_received: 2,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates a new partial purchase shipment" do
        patch purchase_path(purchase), params: valid_parameters
        purchase.reload
        aggregate_failures do
          expect(response).to have_http_status :found
          expect(response).to redirect_to edit_purchase_path(purchase)
          expect(purchase.purchase_details.first.purchase_shipments.count).to eq(1)
        end
      end
    end

    describe "removing a shipment" do
      let!(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:valid_parameters) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase.purchase_details.first.id,
                purchase_shipments_attributes: [
                  {
                    id: purchase.purchase_details.first.purchase_shipments.last.id,
                    _destroy: true
                  }
                ]
              }
            ]
          }
        }
      end

      it "removes the shipment" do
        aggregate_failures do
          expect { patch purchase_path(purchase), params: valid_parameters }.to(
            change { purchase.purchase_details.first.purchase_shipments.count }.by(-1)
          )
        end
      end
    end

    describe "updating tax and shipping costs for a shipped purchase" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            tax: "15.25",
            shipping_cost: "10.75"
          }
        }
      end

      it "updates the values" do
        patch purchase_path(purchase), params: params
        purchase.reload
        expect(purchase.tax).to eq(15.25)
        expect(purchase.shipping_cost).to eq(10.75)
      end
    end

    describe "adding a purchase_shipment for a shipped purchase" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase_detail.id,
                purchase_shipments_attributes: [
                  {
                    quantity_received: 2,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates a new partial purchase shipment" do
        expect { patch purchase_path(purchase), params: params }.to change(PurchaseShipment, :count).by(1)
      end
    end

    describe "adding a purchase_shipment with quantity more than what is specified with confirmed overage" do
      let(:receiving_detail) { purchase_details(:small_flip_flops_purchase_detail) }
      let(:item) { items(:small_flip_flops) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: receiving_detail.id,
                overage_confirmed: "13",
                purchase_shipments_attributes: [
                  {
                    quantity_received: 25,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates shipment, updates the detail quantity, and adds the stock" do
        expect(item.current_quantity).to eq(42)
        expect { patch purchase_path(purchase), params: params }.to change(PurchaseShipment, :count).by(1)

        receiving_detail.reload
        expect(receiving_detail.quantity).to eq(25)

        item.reload
        expect(item.current_quantity).to eq(67)
      end
    end

    describe "adding a purchase_shipment with quantity more than what is specified when there were already shipments received with confirmed overage" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:receiving_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }
      let(:item) { items(:small_flip_flops) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: receiving_detail.id,
                overage_confirmed: "22",
                purchase_shipments_attributes: [
                  {
                    quantity_received: 25,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates shipment, updates the detail quantity, and adds the stock" do
        expect(item.current_quantity).to eq(42)
        expect(receiving_detail.purchase_shipments.sum(:quantity_received)).to eq(9)
        expect { patch purchase_path(purchase), params: params }.to change(PurchaseShipment, :count).by(1)

        receiving_detail.reload
        expect(receiving_detail.quantity).to eq(34)

        item.reload
        expect(item.current_quantity).to eq(67)
      end
    end

    describe "adding a purchase_shipment with quantity more than what is specified with mismatched overage" do
      let(:receiving_detail) { purchase_details(:small_flip_flops_purchase_detail) }
      let(:item) { items(:small_flip_flops) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: receiving_detail.id,
                overage_confirmed: "5",
                purchase_shipments_attributes: [
                  {
                    quantity_received: 25,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "prevents the shipment and doesn't update quantity or item stock" do
        expect(item.current_quantity).to eq(42)
        expect { patch purchase_path(purchase), params: params }.not_to change(PurchaseShipment, :count)

        receiving_detail.reload
        expect(receiving_detail.quantity).to eq(12)

        item.reload
        expect(item.current_quantity).to eq(42)
      end
    end

    describe "adding a purchase_shipment with quantity more than what is specified when there were already shipments received with mismatched overage" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:receiving_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }
      let(:item) { items(:small_flip_flops) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: receiving_detail.id,
                overage_confirmed: "7",
                purchase_shipments_attributes: [
                  {
                    quantity_received: 25,
                    received_date: Time.current
                  }
                ]
              }
            ]
          }
        }
      end

      it "prevents the shipment and doesn't update quantity or item stock" do
        expect(item.current_quantity).to eq(42)
        expect(receiving_detail.purchase_shipments.sum(:quantity_received)).to eq(9)
        expect { patch purchase_path(purchase), params: params }.not_to change(PurchaseShipment, :count)

        receiving_detail.reload
        expect(receiving_detail.quantity).to eq(12)

        item.reload
        expect(item.current_quantity).to eq(42)
      end
    end

    describe "adding a purchase short for a shorted purchase" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase_detail.id,
                purchase_shorts_attributes: [
                  {
                    quantity_shorted: 2
                  }
                ]
              }
            ]
          }
        }
      end

      it "creates a new purchase short and removes the quantity from the detail" do
        expect(purchase_detail.quantity).to eq(12)
        expect { patch purchase_path(purchase), params: params }.to change(PurchaseShort, :count).by(1)

        new_short = purchase_detail.purchase_shorts.last
        expect(new_short.quantity_shorted).to eq(2)

        purchase_detail.reload
        expect(purchase_detail.quantity).to eq(10)
      end
    end

    describe "removing a purchase short for a shorted purchase" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }
      let!(:purchase_short) { purchase_detail.purchase_shorts.create!(quantity_shorted: 2) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase_detail.id,
                purchase_shorts_attributes: [
                  {
                    id: purchase_short.id,
                    _destroy: true
                  }
                ]
              }
            ]
          }
        }
      end

      it "removes the purchase short and doesn't change the quantity from the detail" do
        expect(purchase_detail.quantity).to eq(10)
        expect { patch purchase_path(purchase), params: params }.to change(PurchaseShort, :count).by(-1)

        expect(PurchaseShort.find_by(id: purchase_short.id)).to be_nil

        purchase_detail.reload
        expect(purchase_detail.quantity).to eq(10)
      end
    end

    describe "attempting to add a purchase short with more shorted than is remaining" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase_detail.id,
                purchase_shorts_attributes: [
                  {
                    quantity_shorted: 5
                  }
                ]
              }
            ]
          }
        }
      end

      it "prevents the short from being created and doesn't update the purchase detail quantity" do
        expect(purchase_detail.quantity).to eq(12)
        expect(purchase_detail.quantity_remaining).to eq(3)
        expect { patch purchase_path(purchase), params: params }.not_to change(PurchaseShort, :count)

        purchase_detail.reload
        expect(purchase_detail.quantity).to eq(12)
      end
    end

    describe "attempting to add a purchase short and shipment with more shorted than is remaining" do
      let(:purchase) { purchases(:purchase_with_details_and_shipments) }
      let(:purchase_detail) { purchase_details(:small_flip_flops_purchase_detail_with_shipments) }
      let(:item) { items(:small_flip_flops) }

      let(:params) do
        {
          purchase: {
            id: purchase.id,
            purchase_details_attributes: [
              {
                id: purchase_detail.id,
                purchase_shipments_attributes: [
                  {
                    quantity_received: 3,
                    received_date: Time.current
                  }
                ],
                purchase_shorts_attributes: [
                  {
                    quantity_shorted: 2
                  }
                ]
              }
            ]
          }
        }
      end

      it "prevents the short and shipment from being created and doesn't update the purchase detail quantity nor add to stock" do
        expect(item.current_quantity).to eq(42)
        expect(purchase_detail.quantity).to eq(12)
        expect(purchase_detail.quantity_remaining).to eq(3)
        expect { patch purchase_path(purchase), params: params }.not_to change { [PurchaseShort.count, PurchaseShipment.count] }

        purchase_detail.reload
        expect(purchase_detail.quantity).to eq(12)

        item.reload
        expect(item.current_quantity).to eq(42)
      end
    end
  end
end

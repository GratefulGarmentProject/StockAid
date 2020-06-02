require "rails_helper"

RSpec.describe PurchaseDetail do
  let!(:user) { users(:root) }
  let!(:vendor) { vendors(:guinan) }
  let!(:purchase) { purchases(:new_purchase_with_details) }
  let!(:purchase_detail) { purchase.purchase_details.first }
  describe "nested purchase shipments" do
    context "when the quantity received is omitted" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            foo: {
              received_date: Time.zone.today
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        purchase_detail.update(params)
        expect(purchase_detail.purchase_shipments.count).to(eq(0))
      end
    end
    context "when the quantity received is blank" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            foo: {
              quantity_received: ""
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        purchase_detail.update(params)
        expect(purchase_detail.purchase_shipments.count).to(eq(0))
      end
    end
    context "when the quantity received is a negative number" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            bar: {
              quantity_received: -27
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        purchase_detail.update(params)
        expect(purchase_detail.purchase_shipments.count).to(eq(0))
      end
    end
    context "when the quantity received is zero" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            foo: {
              quantity_received: 0
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        purchase_detail.update(params)
        expect(purchase_detail.purchase_shipments.count).to(eq(0))
      end
    end
    context "when the quantity received is greater than 1 but less than the quantity remaining" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            foo: {
              quantity_received: (purchase_detail.quantity_remaining / 2).to_i
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        aggregate_failures do
          expect(purchase_detail.update(params)).to be_truthy, purchase_detail.errors.full_messages.join("\n")
        end
        expect(purchase_detail.purchase_shipments.count).to(eq(1))
      end
    end

    context "when the quantity received is equal to the quantity remaining" do
      let!(:params) do
        ActionController::Parameters.new(
          id: purchase_detail.id,
          purchase_shipments_attributes: {
            foo: {
              quantity_received: purchase_detail.quantity_remaining
            }
          }
        ).permit!
      end

      it "rejects purchase shipment" do
        purchase_detail.update(params)
        expect(purchase_detail.purchase_shipments.count).to(eq(1))
      end
    end
  end
end

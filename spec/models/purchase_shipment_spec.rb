require "rails_helper"

RSpec.describe PurchaseShipment do
  let!(:purchase) { purchases(:new_purchase_with_details) }
  let!(:first_purchase_detail) { purchase.purchase_details.first }

  describe "#create" do
    describe "PurchaseShipment.number" do
      context "no PurchaseShipment records yet" do
        it "creates a PurchaseShipment with the number 1" do
          aggregate_failures do
            purchase_shipment = PurchaseShipment.new(
              purchase_detail_id: purchase.purchase_details.first.id,
              quantity_received: 2
            )
            expect(purchase_shipment).to be_valid
            expect(purchase_shipment.number).to eq(1)
            expect(purchase_shipment.received_at).not_to be_nil
          end
        end
      end
      context "an existing PurchaseShipment" do
        let!(:first_purchase_shipment) do
          PurchaseShipment.create!(
            purchase_detail_id: first_purchase_detail.id,
            quantity_received: 1
          )
        end
        it "second PurchaseShipment gets the next number" do
          second_purchase_shipment = PurchaseShipment.new(
            purchase_detail_id: first_purchase_detail.id,
            quantity_received: 2
          )
          aggregate_failures do
            expect(second_purchase_shipment).to be_valid # must be first
            expect(second_purchase_shipment.number).not_to eq(first_purchase_shipment.number)
            expect(second_purchase_shipment.number).to be > first_purchase_shipment.number
          end
        end
      end
      context "cannot duplicate PurchaseShipment numbers within a PurchaseDetail scope" do
        let!(:first_purchase_shipment) do
          PurchaseShipment.create!(
            purchase_detail_id: first_purchase_detail.id,
            quantity_received: 1
          )
        end
        it "second PurchaseShipment with the same number fails" do
          second_purchase_shipment = PurchaseShipment.new(
            purchase_detail_id: first_purchase_detail.id,
            quantity_received: 2,
            number: first_purchase_shipment.number
          )
          aggregate_failures do
            expect(second_purchase_shipment).not_to be_valid # must be first
            expect(second_purchase_shipment.errors.details)
              .to(
                match(
                  hash_including(
                    number: array_including(
                      hash_including(error: :taken)
                    )
                  )
                )
              )
          end
        end
      end
    end
  end
end

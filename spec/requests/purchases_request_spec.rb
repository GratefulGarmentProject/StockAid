require 'rails_helper'

RSpec.describe PurchasesController, type: :request do

  describe '#create' do
    let!(:vendor) { vendors(:guinan)}
    let!(:item1) { items(:small_flip_flops)}
    let!(:item2) { items(:medium_pants)}

    let(:valid_parameters) do
      {
          purchase: {
              vendor_id: vendor.id,
              po: "123456aaaa",
              purchase_date: 1.day.ago,
              tax: "8.95",
              shipping_cost: "7.99",
              purchase_details_attributes: {
                  a: {
                      id: "",
                      item_id: item1.id,
                      quantity: "12",
                      cost: "2",
                      line_cost: "24"
                  },
                  b: {
                      id: "",
                      item_id: item2.id,
                      quantity: "7",
                      cost: "0.1",
                      line_cost: "0.7"
                  }
              }
          }
      }
    end

    before { signed_in_user :root }

    it "should create a new purchase, updating the purchase count" do
      post "/purchases", params: valid_parameters
      expect(response).to have_http_status :ok
    end
  end
end
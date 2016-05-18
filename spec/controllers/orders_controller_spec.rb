require "rails_helper"

describe OrdersController, type: :controller do
  let(:foo_inc) { organizations(:foo_inc) }
  let(:foo_inc_normal) { users(:foo_inc_normal) }

  describe "POST create from select_items" do
    let(:valid_order_params) {
      {
        order: {
          organization_id: foo_inc.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: [3]
          }
        }
      }
    }

    let(:invalid_order_params) {
      {
        order: {
          organization_id: "999999",
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: [3]
          }
        }
      }
    }

    it "creates an order assigned to the selected organization" do
      signed_in_user :foo_inc_normal
      post :create, valid_order_params
      order = Order.first

      expect(order.organization_id).to eq(foo_inc.id)
    end

    it "fails if user isn't affiliated with selected organization" do
      expect do
        signed_in_user :acme_normal
        post :create, valid_order_params
      end.to raise_error(PermissionError)
    end

    it "fails if organization doesn't exist" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, invalid_order_params
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "creates an order_details containing the correct item and quantity" do
      signed_in_user :foo_inc_normal
      post :create, valid_order_params
      order = Order.first

      expect(order.user_id).to eq(foo_inc_normal.id)
      expect(order.order_details.first.item_id).to eq(items(:underwear_men_s).id)
      expect(order.order_details.first.quantity).to eq(3)
    end

    it "creates an order that contains items requested"
    it "fails if the quantity of an item requested is greater than available"
    it "fails if the quantity of an item requested is 0"
    it "fails if the quantity of an item requested is negative"
    it "fails if the same item is requested multiple times"
    it "fails if there is a partial item description"
  end

  describe "PUT update from select_items" do
  end
end

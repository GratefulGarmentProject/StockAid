require "rails_helper"

RSpec.describe OrdersController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get orders_path
      expect(response).to have_http_status(:ok)
    end

    context "as org user (non-super-admin)" do
      before { sign_in users(:acme_root) }

      it "renders ok and uses non-super-admin path" do
        get orders_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#closed" do
    it "renders ok" do
      get closed_orders_path
      expect(response).to have_http_status(:ok)
    end

    context "as org user (non-super-admin)" do
      before { sign_in users(:acme_root) }

      it "renders ok and uses non-super-admin path" do
        get closed_orders_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#rejected" do
    it "renders ok" do
      get rejected_orders_path
      expect(response).to have_http_status(:ok)
    end

    context "as org user (non-super-admin)" do
      before { sign_in users(:acme_root) }

      it "renders ok and uses non-super-admin path" do
        get rejected_orders_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#canceled" do
    it "renders ok" do
      get canceled_orders_path
      expect(response).to have_http_status(:ok)
    end

    context "as org user (non-super-admin)" do
      before { sign_in users(:acme_root) }

      it "renders ok and uses non-super-admin path" do
        get canceled_orders_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_order_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an order and redirects to edit" do
      post orders_path, params: { order: { organization_id: organizations(:acme).id } }
      expect(response).to have_http_status(:found)
      order = Order.order(:id).last
      expect(response).to redirect_to(edit_order_path(order))
    end
  end

  describe "#edit" do
    it "renders ok for an open order" do
      get edit_order_path(orders(:open_order))
      expect(response).to have_http_status(:ok)
    end

    it "renders the select_items status view for a select_items order" do
      order = Order.create!(
        organization: organizations(:acme),
        user: super_admin,
        order_date: Time.zone.now,
        status: :select_items,
        ship_to_name: "Select Items Test",
        ship_to_address: "123 Select St."
      )
      get edit_order_path(order)
      expect(response).to have_http_status(:ok)
    end

    context "with a non-super user" do
      before { sign_in users(:acme_root) }

      it "redirects non-admins away from orders they can't edit" do
        get edit_order_path(orders(:open_order))
        expect(response).to redirect_to(orders_path)
      end
    end
  end

  describe "#update" do
    describe "approve" do
      let(:pending_order) { orders(:pending_order) }

      it "approves the order" do
        patch order_path(pending_order), params: { order: { status: "approve" } }
        expect(response).to have_http_status(:found)
        expect(pending_order.reload).to be_approved
      end
    end

    describe "hold (approved → pending)" do
      let(:open_order) { orders(:open_order) }

      it "puts the order on hold" do
        patch order_path(open_order), params: { order: { status: "hold" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload).to be_pending
      end
    end

    describe "allocate" do
      let(:open_order) { orders(:open_order) }

      it "allocates the order" do
        patch order_path(open_order), params: { order: { status: "allocate" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload).to be_filled
      end
    end

    describe "ship (filled → shipped)" do
      let(:item) { items(:small_flip_flops) }
      let!(:filled_order) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :filled,
          ship_to_name: "Ship Test",
          ship_to_address: "123 Ship St."
        ).tap { |o| o.order_details.create!(item: item, quantity: 2, value: item.value) }
      end

      it "ships the order and subtracts item quantities" do
        original_qty = item.current_quantity
        patch order_path(filled_order), params: { order: { status: "ship" } }
        expect(response).to have_http_status(:found)
        expect(filled_order.reload).to be_shipped
        expect(item.reload.current_quantity).to eq(original_qty - 2)
      end
    end

    describe "submit_order with order details (confirm_order → pending)" do
      let!(:confirm_order_with_details) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :confirm_order,
          ship_to_name: "Submit Receiver",
          ship_to_address: "123 Submit St."
        ).tap { |o| o.order_details.create!(item: items(:small_flip_flops), quantity: 3, value: 5.0) }
      end

      it "submits and sets requested_quantity on details" do
        patch order_path(confirm_order_with_details), params: { order: { status: "submit_order" } }
        expect(response).to have_http_status(:found)
        expect(confirm_order_with_details.reload).to be_pending
        detail = confirm_order_with_details.order_details.first
        expect(detail.requested_quantity).to eq(3)
      end
    end

    describe "cancel from shipped state" do
      let(:item) { items(:small_flip_flops) }
      let!(:shipped_order) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :shipped,
          ship_to_name: "Cancel Ship",
          ship_to_address: "123 Cancel St."
        ).tap { |o| o.order_details.create!(item: item, quantity: 1, value: item.value) }
      end

      it "restores item quantities when canceling from shipped" do
        original_qty = item.current_quantity
        patch order_path(shipped_order), params: { order: { status: "cancel" } }
        expect(response).to have_http_status(:found)
        expect(shipped_order.reload).to be_canceled
        expect(item.reload.current_quantity).to eq(original_qty + 1)
      end
    end

    describe "confirm_ship_to (select_ship_to → confirm_order)" do
      let!(:select_ship_to_order) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :select_ship_to,
          ship_to_name: "Confirm Ship",
          ship_to_address: "123 Confirm St."
        ).tap { |o| o.order_details.create!(item: items(:small_flip_flops), quantity: 0, value: 5.0) }
      end

      it "transitions to confirm_order and destroys zero-quantity details" do
        expect(select_ship_to_order.order_details.count).to eq(1)
        patch order_path(select_ship_to_order), params: { order: { status: "confirm_ship_to" } }
        expect(response).to have_http_status(:found)
        expect(select_ship_to_order.reload).to be_confirm_order
        expect(select_ship_to_order.order_details.count).to eq(0)
      end
    end

    describe "cancel without survey" do
      let(:open_order) { orders(:open_order) }

      it "cancels the order" do
        patch order_path(open_order), params: { order: { status: "cancel" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload).to be_canceled
      end
    end

    describe "update ship_to_name" do
      let(:open_order) { orders(:open_order) }

      it "updates and redirects to edit" do
        patch order_path(open_order), params: { order: { ship_to_name: "Updated Receiver" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload.ship_to_name).to eq("Updated Receiver")
      end
    end

    describe "update notes" do
      let(:open_order) { orders(:open_order) }

      it "updates notes and redirects" do
        patch order_path(open_order), params: { order: { notes: "Updated notes text" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload.notes).to eq("Updated notes text")
      end
    end

    describe "update ship_to_address" do
      let(:open_order) { orders(:open_order) }

      it "updates address and redirects" do
        patch order_path(open_order), params: { order: { ship_to_address: "456 New Address Ave" } }
        expect(response).to have_http_status(:found)
        expect(open_order.reload.ship_to_address).to eq("456 New Address Ave")
      end
    end

    describe "update with tracking_details" do
      let(:open_order) { orders(:open_order) }

      it "adds tracking details and redirects" do
        patch order_path(open_order), params: {
          order: {
            tracking_details: {
              tracking_number: ["TRACK12345"],
              shipping_carrier: ["1"]
            }
          }
        }
        expect(response).to have_http_status(:found)
        expect(open_order.reload.tracking_details.count).to be >= 1
      end
    end

    describe "update with order_details" do
      let(:item1) { items(:small_flip_flops) }
      let(:item2) { items(:medium_flip_flops) }
      let!(:order_with_details) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :approved,
          ship_to_name: "Detail Receiver",
          ship_to_address: "123 Detail St."
        ).tap do |o|
          o.order_details.create!(item: item1, quantity: 5, value: item1.value)
        end
      end

      it "updates existing details and adds new ones" do
        patch order_path(order_with_details), params: {
          order: {
            order_details: {
              item_id: [item1.id.to_s, item2.id.to_s],
              quantity: %w[3 7]
            }
          }
        }
        expect(response).to have_http_status(:found)
        order_with_details.reload
        detail1 = order_with_details.order_details.find_by(item_id: item1.id)
        expect(detail1.quantity).to eq(3)
        detail2 = order_with_details.order_details.find_by(item_id: item2.id)
        expect(detail2.quantity).to eq(7)
      end
    end

    describe "reject" do
      let(:pending_order) { orders(:pending_order) }

      it "rejects the order and sends an email" do
        allow(OrderMailer).to receive(:order_denied).and_return(double(deliver_now: nil))
        patch order_path(pending_order), params: {
          order: { status: "reject" },
          email: { reason: "Out of stock" }
        }
        expect(response).to have_http_status(:found)
        expect(pending_order.reload).to be_rejected
      end
    end

    describe "submit_order (confirm_order → pending)" do
      let!(:confirm_order) do
        Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :confirm_order,
          ship_to_name: "Test Receiver",
          ship_to_address: "123 Test St."
        )
      end

      it "submits and transitions to pending" do
        patch order_path(confirm_order), params: { order: { status: "submit_order" } }
        expect(response).to have_http_status(:found)
        expect(confirm_order.reload).to be_pending
      end
    end

    describe "cancel a confirm_order that requires survey answers" do
      let!(:survey) do
        Survey.create!(title: "Cancellation Test Survey").tap do |s|
          s.survey_revisions.create!(
            title: "v1",
            active: true,
            definition: { "fields" => [{ "type" => "text", "label" => "Test Question" }] }
          )
        end
      end

      let!(:order) do
        programs(:resource_closets).surveys << survey

        order = Order.create!(
          organization: organizations(:acme),
          user: super_admin,
          order_date: Time.zone.now,
          status: :confirm_order,
          ship_to_name: "Test Receiver",
          ship_to_address: "123 Test St."
        )
        order.order_details.create!(item: items(:small_flip_flops), quantity: 2, value: items(:small_flip_flops).value)
        order
      end

      let(:cancel_params) do
        revision = survey.active_revision
        {
          order: { status: "cancel" },
          # The confirm_order form always submits the revision hidden input even
          # when the Cancel Order button is clicked before filling in answers.
          # This is what the browser actually sends — no :answers key.
          survey_answers: {
            survey.id.to_s => { revision: revision.id.to_s }
          }
        }
      end

      it "cancels the order successfully without raising on missing survey answers" do
        patch order_path(order), params: cancel_params
        expect(response).to have_http_status(:found)
        expect(order.reload).to be_canceled
      end
    end
  end

  describe "#sync" do
    let(:closed_order) { orders(:closed_order) }

    it "syncs the order and enqueues export job" do
      expect do
        post sync_order_path(closed_order)
      end.to have_enqueued_job(ExportOrderJob).with(closed_order.id)
      expect(response).to redirect_to(edit_order_path(closed_order))
    end

    context "with a non-super user" do
      before { sign_in users(:acme_root) }

      it "raises PermissionError" do
        expect { post sync_order_path(closed_order) }.to raise_error(PermissionError)
      end
    end
  end

  describe "#survey_answers" do
    it "renders ok" do
      get survey_answers_order_path(orders(:open_order))
      expect(response).to have_http_status(:ok)
    end
  end
end

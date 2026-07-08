require "rails_helper"

RSpec.describe OrdersController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#update" do
    describe "canceling a confirm_order that requires survey answers" do
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
end

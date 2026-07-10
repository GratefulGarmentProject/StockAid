require "rails_helper"

describe OrderMailer, type: :mailer do
  let(:order) { orders(:open_order) }

  describe "#order_denied" do
    let(:mail) { described_class.order_denied(order, "Out of stock") }

    it "sends to the order user's email" do
      expect(mail.to).to include(order.user.email)
    end

    it "includes the organization name in the subject" do
      expect(mail.subject).to include(order.organization.name)
    end

    it "delivers successfully" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end

require "rails_helper"

describe AddressChangeMailer, type: :mailer do
  let(:user) { users(:root) }
  let(:organization) { organizations(:acme) }

  describe "#change" do
    let(:mail) { described_class.change(user, organization, "123 Old St", "456 New Ave") }

    it "sends to the user's email" do
      expect(mail.to).to include(user.email)
    end

    it "includes the organization name in the subject" do
      expect(mail.subject).to include(organization.name)
    end

    it "delivers the email" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end

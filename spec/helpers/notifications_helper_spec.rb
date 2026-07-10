require "rails_helper"

RSpec.describe NotificationsHelper, type: :helper do
  describe "#notification_reference_link" do
    context "when notification has no reference" do
      let(:notification) { double(reference: nil) }

      it "returns nil" do
        expect(helper.notification_reference_link(notification)).to be_nil
      end
    end

    context "when reference is a Donation" do
      let(:donation) { donations(:picards_donation) }
      let(:notification) { double(reference: donation) }

      it "returns a link to the donation" do
        result = helper.notification_reference_link(notification)
        expect(result).to include("Donation #{donation.id}")
        expect(result).to include("donation")
      end
    end

    context "when reference is an Item" do
      let(:item) { items(:small_flip_flops) }
      let(:notification) { double(reference: item) }

      it "returns a link with the item description" do
        result = helper.notification_reference_link(notification)
        expect(result).to include(item.description)
      end
    end

    context "when reference is an unknown type" do
      let(:notification) { double(reference: Object.new) }

      it "returns a fallback string" do
        result = helper.notification_reference_link(notification)
        expect(result).to include("unable to be determined")
      end
    end
  end
end

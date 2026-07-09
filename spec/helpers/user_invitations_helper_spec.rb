require "rails_helper"

RSpec.describe UserInvitationsHelper, type: :helper do
  describe "#nearby_expiration_class" do
    it "returns 'text-danger' when expiration is within 1 day" do
      date = Time.zone.now - 12.hours
      expect(helper.nearby_expiration_class(date)).to eq("text-danger")
    end

    it "returns 'text-warning' when expiration is within 3 days" do
      date = Time.zone.now - 2.days
      expect(helper.nearby_expiration_class(date)).to eq("text-warning")
    end

    it "returns nil when expiration is more than 3 days away" do
      date = Time.zone.now - 5.days
      expect(helper.nearby_expiration_class(date)).to be_nil
    end
  end

  describe "#row_color_class" do
    let(:expired_invite) { double(expired?: true, expires_at: 2.days.ago) }
    let(:expiring_soon_invite) { double(expired?: false, expires_at: Time.zone.now + 12.hours) }
    let(:expiring_warning_invite) { double(expired?: false, expires_at: Time.zone.now + 3.days) }
    let(:normal_invite) { double(expired?: false, expires_at: Time.zone.now + 10.days) }

    it "returns 'text-danger' for expired invites" do
      expect(helper.row_color_class(expired_invite)).to eq("text-danger")
    end

    it "returns 'danger' for invites expiring within 1 day" do
      expect(helper.row_color_class(expiring_soon_invite)).to eq("danger")
    end

    it "returns 'warning' for invites expiring within 5 days" do
      expect(helper.row_color_class(expiring_warning_invite)).to eq("warning")
    end

    it "returns nil for invites not expiring soon" do
      expect(helper.row_color_class(normal_invite)).to be_nil
    end
  end
end

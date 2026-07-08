require "rails_helper"

describe Notification, type: :model do
  describe "#read? / #unread?" do
    context "with completed_at set" do
      let(:notification) { notifications(:read_notification) }

      it "is read" do
        expect(notification).to be_read
        expect(notification).not_to be_unread
      end
    end

    context "without completed_at" do
      let(:notification) { notifications(:unread_notification) }

      it "is unread" do
        expect(notification).to be_unread
        expect(notification).not_to be_read
      end
    end
  end

  describe ".notify_deleted_donation" do
    let(:current_user) { users(:root) }
    let(:donation) { donations(:picards_donation) }

    it "creates notifications for subscribed users" do
      expect {
        Notification.notify_deleted_donation(current_user, donation)
      }.to change(Notification, :count).by(1)
    end
  end

  describe ".notify_spoilage" do
    let(:current_user) { users(:root) }
    let(:item) { items(:small_flip_flops) }

    context "with edit_reason: spoilage" do
      let(:params) do
        ActionController::Parameters.new(
          edit_amount: "5",
          edit_method: "subtract",
          edit_reason: "spoilage",
          edit_source: "Damaged in storage"
        )
      end

      it "creates a spoilage notification for subscribed users" do
        expect {
          Notification.notify_spoilage(current_user, item, params)
        }.to change(Notification, :count).by(1)
      end
    end

    context "with a different edit_reason" do
      let(:params) do
        ActionController::Parameters.new(
          edit_amount: "5",
          edit_method: "subtract",
          edit_reason: "adjustment",
          edit_source: "Manual count"
        )
      end

      it "does not create a notification" do
        expect {
          Notification.notify_spoilage(current_user, item, params)
        }.not_to change(Notification, :count)
      end
    end
  end
end

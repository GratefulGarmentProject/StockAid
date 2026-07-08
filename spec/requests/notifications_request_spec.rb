require "rails_helper"

RSpec.describe NotificationsController, type: :request do
  let(:root_user) { users(:root) }

  before { sign_in root_user }

  describe "#index" do
    it "renders ok" do
      get notifications_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get notification_path(notifications(:unread_notification))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    context "mark_read" do
      let(:notification) { notifications(:unread_notification) }

      it "marks the notification as read and redirects" do
        patch notification_path(notification), params: { mark_read: "true" }
        expect(response).to redirect_to(notifications_path)
        expect(flash[:success]).to be_present
        expect(notification.reload).to be_read
      end
    end

    context "mark_unread" do
      let(:notification) { notifications(:read_notification) }

      it "marks the notification as unread and redirects" do
        patch notification_path(notification), params: { mark_unread: "true" }
        expect(response).to redirect_to(notifications_path)
        expect(flash[:success]).to be_present
        expect(notification.reload).to be_unread
      end
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get notifications_path }.to raise_error(PermissionError)
    end
  end
end

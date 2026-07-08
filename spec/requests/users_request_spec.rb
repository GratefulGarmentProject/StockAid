require "rails_helper"

RSpec.describe UsersController, type: :request do
  let(:super_admin) { users(:root) }
  let(:target_user) { users(:acme_normal) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get users_path
      expect(response).to have_http_status(:ok)
    end

    context "with a non-admin user" do
      before { sign_in target_user }

      it "raises PermissionError" do
        expect { get users_path }.to raise_error(PermissionError)
      end
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_user_path(target_user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    context "updating another user" do
      it "updates the user and redirects to users_path" do
        patch user_path(target_user), params: { id: target_user.id, user: { name: "New Name" } }
        expect(response).to redirect_to(users_path)
        expect(target_user.reload.name).to eq("New Name")
      end
    end

    context "updating self" do
      it "updates and redirects to root_path" do
        patch user_path(super_admin), params: {
          id: super_admin.id,
          user: { name: super_admin.name },
          subscriptions: { spoilage: "false", deleted_donations: "false", deleted_purchases: "false" }
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#destroy" do
    it "destroys the user and redirects" do
      delete user_path(target_user)
      expect(response).to redirect_to(users_path)
    end
  end

  describe "#reset_password" do
    it "sends a password reset email and redirects" do
      expect {
        post reset_password_user_path(target_user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response).to redirect_to(users_path)
      expect(flash[:success]).to include(target_user.name)
    end
  end

  describe "#export" do
    it "returns a CSV response" do
      get export_users_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end
end

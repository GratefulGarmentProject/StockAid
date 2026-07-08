require "rails_helper"

RSpec.describe UserInvitationsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#open" do
    it "renders ok" do
      get open_user_invitations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#closed" do
    it "renders ok" do
      get closed_user_invitations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_user_invitation_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an invitation and redirects" do
      post user_invitations_path, params: {
        user: {
          organization_id: organizations(:acme).id,
          name: "New Invitee",
          email: "new_invitee_unique@test.example.com",
          role: "none"
        }
      }
      expect(response).to redirect_to(users_path)
    end
  end

  describe "#show (no auth required)" do
    let(:invite) { user_invitations(:acme_invite) }

    it "renders ok with valid token" do
      get user_invitation_path(invite), params: {
        auth_token: invite.auth_token,
        email: invite.email
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "UserInvitation model" do
    it ".for_organization returns invitations for the given organization" do
      result = UserInvitation.for_organization(organizations(:acme))
      expect(result).to be_an(ActiveRecord::Relation)
    end
  end

  describe "#update (no auth required)" do
    let(:invite) { user_invitations(:acme_invite) }

    it "converts the invitation to a user and redirects" do
      patch user_invitation_path(invite), params: {
        auth_token: invite.auth_token,
        user: {
          name: invite.name,
          email: invite.email,
          primary_number: "(408) 555-7777",
          password: "SecurePass123!",
          password_confirmation: "SecurePass123!"
        }
      }
      expect(response).to have_http_status(:found)
    end
  end
end

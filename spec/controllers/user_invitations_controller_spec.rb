require "rails_helper"

describe UserInvitationsController, type: :controller do
  let(:acme) { organizations(:acme) }

  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }

  describe "GET new" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :new
      end.to raise_error(PermissionError)
    end

    it "is allowed for admin users" do
      signed_in_user :acme_root
      get :new
      expect(response).to have_http_status(:success)
    end

    it "is allowed for super admin users" do
      signed_in_user :root
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST create" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        post :create, user: {
          organization_id: acme.id.to_s,
          name: "Foo Bar",
          email: "foobar@email.com",
          role: "none"
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :foo_inc_root

        post :create, user: {
          organization_id: acme.id.to_s,
          name: "Foo Bar",
          email: "foobar@email.com",
          role: "none"
        }
      end.to raise_error(PermissionError)
    end

    it "creates an invite for admin user" do
      signed_in_user :acme_root
      expect(SecureRandom).to receive(:hex).and_return("secure_hex")

      post :create, user: {
        organization_id: acme.id.to_s,
        name: "Foo Bar",
        email: "foobar@email.com",
        role: "none"
      }

      invitation = UserInvitation.find_by_email("foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(acme_root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("none")
      expect(invitation.auth_token).to eq("secure_hex")
    end

    it "creates an invite for super admin user" do
      signed_in_user :root
      expect(SecureRandom).to receive(:hex).and_return("secure_hex")

      post :create, user: {
        organization_id: acme.id.to_s,
        name: "Foo Bar",
        email: "foobar@email.com",
        role: "admin"
      }

      invitation = UserInvitation.find_by_email("foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("admin")
      expect(invitation.auth_token).to eq("secure_hex")
    end

    it "normalizes the email address like devise is configured to do" do
      signed_in_user :acme_root
      expect(SecureRandom).to receive(:hex).and_return("secure_hex")

      post :create, user: {
        organization_id: acme.id.to_s,
        name: "Foo Bar",
        email: "  FooBar@email.com   \t \n ",
        role: "admin"
      }

      invitation = UserInvitation.find_by_email("foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(acme_root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("admin")
      expect(invitation.auth_token).to eq("secure_hex")
    end

    xit "sends an email invite" do
      signed_in_user :acme_root

      post :create, user: {
        organization_id: acme.id.to_s,
        name: "Foo Bar",
        email: "foobar@email.com",
        role: "none"
      }

      # TODO: expect email
    end
  end
end

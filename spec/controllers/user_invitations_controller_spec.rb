require "rails_helper"

describe UserInvitationsController, type: :controller do
  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }

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

    it "immediately adds the user if they already exist" do
      expect(acme_normal.role_at(foo_inc)).to be_nil
      signed_in_user :foo_inc_root

      post :create, user: {
        organization_id: foo_inc.id.to_s,
        name: "Foo Bar",
        email: acme_normal.email,
        role: "none"
      }

      expect(UserInvitation.find_by_email(acme_normal.email)).to be_nil
      acme_normal.reload
      expect(acme_normal.name).to eq("Acme Normal") # It shouldn't change their name
      expect(acme_normal.role_at(foo_inc)).to eq("none")
    end
  end

  describe "GET show" do
    it "fails with the wrong email" do
      invite = user_invitations(:acme_invite)

      expect do
        get :show,
            id: invite.id.to_s,
            auth_token: invite.auth_token,
            email: "faker-wrong@email.com"
      end.to raise_error(PermissionError)
    end

    it "fails with the wrong auth code" do
      invite = user_invitations(:acme_invite)

      expect do
        get :show,
            id: invite.id.to_s,
            auth_token: "fakerwrong123",
            email: invite.email
      end.to raise_error(PermissionError)
    end

    # This shouldn't actually fail, but instead display an expired message
    it "fails with an expired invitation"
  end

  describe "PUT update" do
    it "fails with the wrong email" do
      invite = user_invitations(:acme_invite)

      expect do
        put :update,
            id: invite.id.to_s,
            auth_token: invite.auth_token,
            email: "faker-wrong@email.com",
            name: "Acme Invited",
            phone_number: "(408) 555-5123",
            address: "1234 Main St, San Jose, CA 95123",
            password: "password123",
            password_confirmation: "password123"
      end.to raise_error(PermissionError)
    end

    it "fails with the wrong auth code" do
      invite = user_invitations(:acme_invite)

      expect do
        put :update,
            id: invite.id.to_s,
            auth_token: "fakerwrong123",
            email: invite.email,
            name: "Acme Invited",
            phone_number: "(408) 555-5123",
            address: "1234 Main St, San Jose, CA 95123",
            password: "password123",
            password_confirmation: "password123"
      end.to raise_error(PermissionError)
    end

    it "fails with an expired invitation" do
      invite = user_invitations(:expired_acme_invite)

      expect do
        put :update,
            id: invite.id.to_s,
            auth_token: invite.auth_token,
            email: invite.email,
            name: "Acme Invited",
            phone_number: "(408) 555-5123",
            address: "1234 Main St, San Jose, CA 95123",
            password: "password123",
            password_confirmation: "password123"
      end.to raise_error(PermissionError)
    end

    it "creates the user from the invite" do
      invite = user_invitations(:acme_invite)

      put :update,
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: invite.email,
          name: "Acme Invited",
          phone_number: "(408) 555-5123",
          address: "1234 Main St, San Jose, CA 95123",
          password: "password123",
          password_confirmation: "password123"

      user = User.find_by_email(invite.email)
      expect(user).to be
      expect(user.name).to eq("Acme Invited")
      expect(user.email).to eq(invite.email)
      expect(user.phone_number).to eq("(408) 555-5123")
      expect(user.address).to eq("1234 Main St, San Jose, CA 95123")
      expect(user.role).to eq("none")
    end

    it "grants the user access to the desired organization" do
      invite = user_invitations(:acme_invite)

      put :update,
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: invite.email,
          name: "Acme Invited",
          phone_number: "(408) 555-5123",
          address: "1234 Main St, San Jose, CA 95123",
          password: "password123",
          password_confirmation: "password123"

      user = User.find_by_email(invite.email)
      expect(user.role_at(acme)).to eq("none")
      expect(user.role_at(foo_inc)).to be_nil
    end

    it "grants the user admin access to the desired organization if the desired role was as an admin" do
      invite = user_invitations(:acme_admin_invite)

      put :update,
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: invite.email,
          name: "Acme Invited",
          phone_number: "(408) 555-5123",
          address: "1234 Main St, San Jose, CA 95123",
          password: "password123",
          password_confirmation: "password123"

      user = User.find_by_email(invite.email)
      expect(user.role_at(acme)).to eq("admin")
      expect(user.role_at(foo_inc)).to be_nil
    end

    it "invalidates all outstanding initations if successful" do
      invite = user_invitations(:acme_invite)

      put :update,
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: invite.email,
          name: "Acme Invited",
          phone_number: "(408) 555-5123",
          address: "1234 Main St, San Jose, CA 95123",
          password: "password123",
          password_confirmation: "password123"

      expect(UserInvitation.where(email: invite.email).all?(&:expired?)).to be_truthy
    end
  end
end

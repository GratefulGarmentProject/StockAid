require "rails_helper"

describe UserInvitationsController, type: :controller do
  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }

  let(:acme_invite) { user_invitations(:acme_invite) }
  let(:acme_admin_invite) { user_invitations(:acme_admin_invite) }
  let(:used_acme_invite) { user_invitations(:used_acme_invite) }
  let(:expired_acme_invite) { user_invitations(:expired_acme_invite) }
  let(:foo_inc_invite) { user_invitations(:foo_inc_invite) }
  let(:foo_inc_admin_invite) { user_invitations(:foo_inc_admin_invite) }
  let(:used_foo_invite) { user_invitations(:used_foo_invite) }

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

  describe "GET open" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :open
      end.to raise_error(PermissionError)
    end

    it "shows all open invites for super admin" do
      signed_in_user :root
      get :open
      expect(assigns(:invites)).to include(acme_invite,
                                           acme_admin_invite,
                                           foo_inc_invite,
                                           foo_inc_admin_invite)
      expect(assigns(:invites)).to_not include(used_acme_invite, used_foo_invite)
    end

    it "shows invites that the user can invite to" do
      signed_in_user :acme_root
      get :open
      expect(assigns(:invites)).to include(acme_invite, acme_admin_invite)
      expect(assigns(:invites)).to_not include(foo_inc_invite,
                                               foo_inc_admin_invite,
                                               used_acme_invite,
                                               used_foo_invite)
    end
  end

  describe "GET closed" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :closed
      end.to raise_error(PermissionError)
    end

    it "shows all closed invites for super admin" do
      signed_in_user :root
      get :closed
      expect(assigns(:invites)).to include(used_acme_invite, used_foo_invite)
      expect(assigns(:invites)).to_not include(acme_invite,
                                               acme_admin_invite,
                                               foo_inc_invite,
                                               foo_inc_admin_invite)
    end

    it "shows closed invites that the user can invite to" do
      signed_in_user :acme_root
      get :closed
      expect(assigns(:invites)).to include(used_acme_invite)
      expect(assigns(:invites)).to_not include(acme_invite,
                                               acme_admin_invite,
                                               foo_inc_invite,
                                               foo_inc_admin_invite,
                                               used_foo_invite)
    end
  end

  describe "POST create" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        post :create, params: {
          user: {
            organization_id: acme.id.to_s,
            name: "Foo Bar",
            email: "foobar@email.com",
            role: "none"
          }
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :foo_inc_root

        post :create, params: {
          user: {
            organization_id: acme.id.to_s,
            name: "Foo Bar",
            email: "foobar@email.com",
            role: "none"
          }
        }
      end.to raise_error(PermissionError)
    end

    it "creates an invite for admin user" do
      signed_in_user :acme_root
      expect(SecureRandom).to receive(:urlsafe_base64).and_return("secure_auth_key")

      post :create, params: {
        user: {
          organization_id: acme.id.to_s,
          name: "Foo Bar",
          email: "foobar@email.com",
          role: "none"
        }
      }

      invitation = UserInvitation.find_by(email: "foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(acme_root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("none")
      expect(invitation.auth_token).to eq("secure_auth_key")
    end

    it "creates an invite for super admin user" do
      signed_in_user :root
      expect(SecureRandom).to receive(:urlsafe_base64).and_return("secure_auth_key")

      post :create, params: {
        user: {
          organization_id: acme.id.to_s,
          name: "Foo Bar",
          email: "foobar@email.com",
          role: "admin"
        }
      }

      invitation = UserInvitation.find_by(email: "foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("admin")
      expect(invitation.auth_token).to eq("secure_auth_key")
    end

    it "normalizes the email address like devise is configured to do" do
      signed_in_user :acme_root
      expect(SecureRandom).to receive(:urlsafe_base64).and_return("secure_auth_key")

      post :create, params: {
        user: {
          organization_id: acme.id.to_s,
          name: "Foo Bar",
          email: "  FooBar@email.com   \t \n ",
          role: "admin"
        }
      }

      invitation = UserInvitation.find_by(email: "foobar@email.com")
      expect(invitation).to be
      expect(invitation.invited_by).to eq(acme_root)
      expect(invitation.organization).to eq(acme)
      expect(invitation.name).to eq("Foo Bar")
      expect(invitation.email).to eq("foobar@email.com")
      expect(invitation.role).to eq("admin")
      expect(invitation.auth_token).to eq("secure_auth_key")
    end

    it "sends an email invite" do
      signed_in_user :acme_root
      expect(SecureRandom).to receive(:urlsafe_base64).and_return("secure_auth_key")

      expect do
        post :create, params: {
          user: {
            organization_id: acme.id.to_s,
            name: "Foo Bar",
            email: "foobar@email.com",
            role: "none"
          }
        }
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      invitation = UserInvitation.find_by(email: "foobar@email.com")
      expect(ActionMailer::Base.deliveries.last.to).to match_array("foobar@email.com")
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include("Foo Bar")
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(acme_root.name)
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(acme.name)
      expected_url = user_invitation_url(invitation, email: "foobar@email.com", auth_token: "secure_auth_key")
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(ERB::Util.html_escape(expected_url))
    end

    it "immediately adds the user if they already exist" do
      expect(acme_normal.role_at(foo_inc)).to be_nil
      signed_in_user :foo_inc_root

      post :create, params: {
        user: {
          organization_id: foo_inc.id.to_s,
          name: "Foo Bar",
          email: acme_normal.email,
          role: "none"
        }
      }

      expect(UserInvitation.find_by(email: acme_normal.email)).to be_nil
      acme_normal.reload
      expect(acme_normal.name).to eq("Acme Normal") # It shouldn't change their name
      expect(acme_normal.role_at(foo_inc)).to eq("none")
    end

    it "sends an email notification when the user already exists" do
      expect(acme_normal.role_at(foo_inc)).to be_nil
      signed_in_user :foo_inc_root

      expect do
        post :create, params: {
          user: {
            organization_id: foo_inc.id.to_s,
            name: "Foo Bar",
            email: acme_normal.email,
            role: "none"
          }
        }
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(ActionMailer::Base.deliveries.last.to).to match_array(acme_normal.email)
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(acme_normal.name)
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(foo_inc_root.name)
      expect(ActionMailer::Base.deliveries.last.body.parts.last.to_s).to include(foo_inc.name)
    end
  end

  describe "GET show" do
    it "fails with the wrong email" do
      no_user_signed_in
      invite = acme_invite

      expect do
        get :show, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: "faker-wrong@email.com"
        }
      end.to raise_error(PermissionError)
    end

    it "fails with the wrong auth code" do
      no_user_signed_in
      invite = acme_invite

      expect do
        get :show, params: {
          id: invite.id.to_s,
          auth_token: "fakerwrong123",
          email: invite.email
        }
      end.to raise_error(PermissionError)
    end

    describe "with an expired invitation" do
      render_views

      it "gives a failure message without the form" do
        no_user_signed_in
        invite = expired_acme_invite

        get :show, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          email: invite.email
        }

        expect(response.body).to include("invitation has expired")
        expect(response.body).to_not include("<form")
      end
    end
  end

  describe "PUT update" do
    it "fails with the wrong email" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: "faker-wrong@email.com",
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "Password123",
            password_confirmation: "Password123"
          }
        }
      end.to raise_error(PermissionError)
    end

    it "fails with the wrong auth code" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: "fakerwrong123",
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "Password123",
            password_confirmation: "Password123"
          }
        }
      end.to raise_error(PermissionError)
    end

    it "fails with an expired invitation" do
      no_user_signed_in
      invite = expired_acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "Password123",
            password_confirmation: "Password123"
          }
        }
      end.to raise_error(PermissionError)
    end

    it "fails with a too short password" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "Short1",
            password_confirmation: "Short1"
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails with a password without a capital letter" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails with a password without a lower case letter" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "PASSWORD123",
            password_confirmation: "PASSWORD123"
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails with a password without a number" do
      no_user_signed_in
      invite = acme_invite

      expect do
        put :update, params: {
          id: invite.id.to_s,
          auth_token: invite.auth_token,
          user: {
            email: invite.email,
            name: "Acme Invited",
            primary_number: "(408) 555-5123",
            password: "Password",
            password_confirmation: "Password"
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "creates the user from the invite" do
      no_user_signed_in
      invite = acme_invite

      put :update, params: {
        id: invite.id.to_s,
        auth_token: invite.auth_token,
        user: {
          email: invite.email,
          name: "Acme Invited",
          primary_number: "(408) 555-5123",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }

      user = User.find_by(email: invite.email)
      expect(user).to be
      expect(user.name).to eq("Acme Invited")
      expect(user.email).to eq(invite.email)
      expect(user.primary_number).to eq("(408) 555-5123")
      expect(user.role).to eq("none")
    end

    it "grants the user access to the desired organization" do
      no_user_signed_in
      invite = acme_invite

      put :update, params: {
        id: invite.id.to_s,
        auth_token: invite.auth_token,
        user: {
          email: invite.email,
          name: "Acme Invited",
          primary_number: "(408) 555-5123",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }

      user = User.find_by(email: invite.email)
      expect(user.role_at(acme)).to eq("none")
      expect(user.role_at(foo_inc)).to be_nil
    end

    it "grants the user admin access to the desired organization if the desired role was as an admin" do
      no_user_signed_in
      invite = acme_admin_invite

      put :update, params: {
        id: invite.id.to_s,
        auth_token: invite.auth_token,
        user: {
          email: invite.email,
          name: "Acme Invited",
          primary_number: "(408) 555-5123",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }

      user = User.find_by(email: invite.email)
      expect(user.role_at(acme)).to eq("admin")
      expect(user.role_at(foo_inc)).to be_nil
    end

    it "invalidates all outstanding invitations to the same organization if successful" do
      no_user_signed_in
      invite = acme_invite
      expect(UserInvitation.with_email(invite.email).not_expired.size > 1).to be_truthy

      put :update, params: {
        id: invite.id.to_s,
        auth_token: invite.auth_token,
        user: {
          email: invite.email,
          name: "Acme Invited",
          primary_number: "(408) 555-5123",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }

      expect(UserInvitation.with_email(invite.email).all?(&:expired?)).to be_truthy
    end

    it "automatically adds access to invitations from other organizations if successful" do
      no_user_signed_in
      invite = acme_invite
      foo_inc_root.user_invitations.create! name: acme_invite.name,
                                            email: acme_invite.email,
                                            role: "admin",
                                            organization: foo_inc

      put :update, params: {
        id: invite.id.to_s,
        auth_token: invite.auth_token,
        user: {
          email: invite.email,
          name: "Acme Invited",
          primary_number: "(408) 555-5123",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }

      expect(UserInvitation.with_email(invite.email).all?(&:expired?)).to be_truthy
      user = User.find_by(email: invite.email)
      expect(user.role_at(acme)).to eq("none")
      expect(user.role_at(foo_inc)).to eq("admin")
      expect(user.organization_users.size).to eq(2)
    end
  end
end

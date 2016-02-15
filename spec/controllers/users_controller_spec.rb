require "rails_helper"

describe UsersController, type: :controller do
  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }
  let(:foo_inc_normal) { users(:foo_inc_normal) }

  describe "GET index" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :index
      end.to raise_error(PermissionError)
    end

    it "shows all users for super admin" do
      signed_in_user :root
      get :index
      expect(assigns(:users)).to include(root, acme_root, acme_normal, foo_inc_root, foo_inc_normal)
    end

    it "shows users that the user has access to" do
      signed_in_user :acme_root
      get :index
      expect(assigns(:users)).to include(acme_root, acme_normal)
      expect(assigns(:users)).to_not include(root, foo_inc_root, foo_inc_normal)
    end
  end
end

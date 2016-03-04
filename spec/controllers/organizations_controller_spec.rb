require "rails_helper"

describe OrganizationsController, type: :controller do
  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  describe "POST create" do
    it "is not allowed for admin users" do
      expect do
        signed_in_user :acme_root

        post :create, organization: {
          name: "Bar Corp.",
          address: "123 Main St, Campbell, CA",
          phone_number: "",
          email: ""
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        post :create, organization: {
          name: "Bar Corp.",
          address: "123 Main St, Campbell, CA",
          phone_number: "",
          email: ""
        }
      end.to raise_error(PermissionError)
    end

    it "can be missing email and phone_number" do
      signed_in_user :root

      post :create, organization: {
        name: "Bar Corp.",
        address: "123 Main St, Campbell, CA",
        phone_number: "",
        email: ""
      }

      org = Organization.find_by_name("Bar Corp.")
      expect(org).to be
      expect(org.name).to eq("Bar Corp.")
      expect(org.address).to eq("123 Main St, Campbell, CA")
      expect(org.phone_number).to be_blank
      expect(org.email).to be_blank
    end

    it "can include email and phone_number" do
      signed_in_user :root

      post :create, organization: {
        name: "Bar Corp.",
        address: "123 Main St, Campbell, CA",
        phone_number: "(408) 555-5555",
        email: "bar@barcorp.com"
      }

      org = Organization.find_by_name("Bar Corp.")
      expect(org).to be
      expect(org.name).to eq("Bar Corp.")
      expect(org.address).to eq("123 Main St, Campbell, CA")
      expect(org.phone_number).to eq("(408) 555-5555")
      expect(org.email).to eq("bar@barcorp.com")
    end
  end

  describe "GET edit" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :edit, id: acme.id.to_s
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :acme_root
        get :edit, id: foo_inc.id.to_s
      end.to raise_error(PermissionError)
    end

    it "is allowed for organization admin" do
      signed_in_user :acme_root
      get :edit, id: acme.id.to_s
      expect(assigns(:organization)).to eq(acme)
    end

    it "is allowed for super admin" do
      signed_in_user :root
      get :edit, id: acme.id.to_s
      expect(assigns(:organization)).to eq(acme)
    end
  end

  describe "PUT update" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        put :update, id: acme.id.to_s, organization: {
          name: "ACME Corp.",
          address: "123 Main St, Campbell, CA",
          phone_number: "",
          email: ""
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :foo_inc_root

        put :update, id: acme.id.to_s, organization: {
          name: "ACME Corp.",
          address: "123 Main St, Campbell, CA",
          phone_number: "",
          email: ""
        }
      end.to raise_error(PermissionError)
    end

    it "is allowed for organization admin" do
      expect(acme.address).to_not eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to_not eq("(408) 555-1234")
      expect(acme.email).to_not eq("user@acme.com")
      signed_in_user :acme_root

      put :update, id: acme.id.to_s, organization: {
        name: "ACME",
        address: "123 Main St, Campbell, CA",
        phone_number: "(408) 555-1234",
        email: "user@acme.com"
      }

      acme.reload
      expect(acme.address).to eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to eq("(408) 555-1234")
      expect(acme.email).to eq("user@acme.com")
    end

    it "is allowed for super admin" do
      expect(acme.address).to_not eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to_not eq("(408) 555-1234")
      expect(acme.email).to_not eq("user@acme.com")
      signed_in_user :root

      put :update, id: acme.id.to_s, organization: {
        name: "ACME Corp.",
        address: "123 Main St, Campbell, CA",
        phone_number: "(408) 555-1234",
        email: "user@acme.com"
      }

      acme.reload
      expect(acme.address).to eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to eq("(408) 555-1234")
      expect(acme.email).to eq("user@acme.com")
    end

    it "blocks changes to organization name for organization admin" do
      expect(acme.name).to eq("ACME")
      signed_in_user :acme_root

      put :update, id: acme.id.to_s, organization: {
        name: "ACME Corp.",
        address: "123 Main St, Campbell, CA",
        phone_number: "(408) 555-1234",
        email: "user@acme.com"
      }

      acme.reload
      expect(acme.name).to eq("ACME")
    end

    it "allows changes to organization name for super admin" do
      expect(acme.name).to eq("ACME")
      signed_in_user :root

      put :update, id: acme.id.to_s, organization: {
        name: "ACME Corp.",
        address: "123 Main St, Campbell, CA",
        phone_number: "(408) 555-1234",
        email: "user@acme.com"
      }

      acme.reload
      expect(acme.name).to eq("ACME Corp.")
    end
  end
end

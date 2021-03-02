require "rails_helper"

describe OrganizationsController, type: :controller do
  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  let(:no_order_org) { organizations(:no_order_org) }
  let(:open_order_org) { organizations(:open_order_org) }
  let(:rejected_order_org) { organizations(:rejected_order_org) }
  let(:closed_order_org) { organizations(:closed_order_org) }

  let(:open_order) { orders(:open_order) }
  let(:rejected_order) { orders(:rejected_order) }
  let(:closed_order) { orders(:closed_order) }

  let(:resource_closets) { programs(:resource_closets) }

  describe "POST create" do
    it "is not allowed for admin users" do
      expect do
        signed_in_user :acme_root

        post :create, params: {
          organization: {
            name: "Bar Corp.",
            phone_number: "",
            email: "",
            addresses_attributes: {
              "0" => { address: "123 Main St, Campbell, CA" }
            },
            program_ids: [resource_closets.id]
          }
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        post :create, params: {
          organization: {
            name: "Bar Corp.",
            phone_number: "",
            email: "",
            addresses_attributes: {
              "0" => { address: "123 Main St, Campbell, CA" }
            },
            program_ids: [resource_closets.id]
          }
        }
      end.to raise_error(PermissionError)
    end

    it "can be missing email and phone_number" do
      signed_in_user :root

      post :create, params: {
        organization: {
          name: "Bar Corp.",
          phone_number: "",
          email: "",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          },
          program_ids: [resource_closets.id]
        }
      }

      org = Organization.find_by(name: "Bar Corp.")
      expect(org).to be
      expect(org.name).to eq("Bar Corp.")
      expect(org.primary_address.to_s).to eq("123 Main St, Campbell, CA")
      expect(org.phone_number).to be_blank
      expect(org.email).to be_blank
    end

    it "can include email and phone_number" do
      signed_in_user :root

      post :create, params: {
        organization: {
          name: "Bar Corp.",
          phone_number: "(408) 555-5555",
          email: "bar@barcorp.com",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          },
          program_ids: [resource_closets.id]
        }
      }

      org = Organization.find_by(name: "Bar Corp.")
      expect(org).to be
      expect(org.name).to eq("Bar Corp.")
      expect(org.primary_address.to_s).to eq("123 Main St, Campbell, CA")
      expect(org.phone_number).to eq("(408) 555-5555")
      expect(org.email).to eq("bar@barcorp.com")
    end
  end

  describe "GET edit" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal
        get :edit, params: { id: acme.id.to_s }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :acme_root
        get :edit, params: { id: foo_inc.id.to_s }
      end.to raise_error(PermissionError)
    end

    it "is allowed for organization admin" do
      signed_in_user :acme_root
      get :edit, params: { id: acme.id.to_s }
      expect(assigns(:organization)).to eq(acme)
    end

    it "is allowed for super admin" do
      signed_in_user :root
      get :edit, params: { id: acme.id.to_s }
      expect(assigns(:organization)).to eq(acme)
    end
  end

  describe "PUT update" do
    it "is not allowed for normal users" do
      expect do
        signed_in_user :acme_normal

        put :update, params: {
          id: acme.id.to_s,
          organization: {
            name: "ACME Corp.",
            phone_number: "",
            email: "",
            addresses_attributes: {
              "0" => { address: "123 Main St, Campbell, CA" }
            },
            program_ids: [resource_closets.id]
          }
        }
      end.to raise_error(PermissionError)
    end

    it "is not allowed for admin users of another company" do
      expect do
        signed_in_user :foo_inc_root

        put :update, params: {
          id: acme.id.to_s,
          organization: {
            name: "ACME Corp.",
            phone_number: "",
            email: "",
            addresses_attributes: {
              "0" => { address: "123 Main St, Campbell, CA" }
            },
            program_ids: [resource_closets.id]
          }
        }
      end.to raise_error(PermissionError)
    end

    it "is allowed for organization admin" do
      expect(acme.addresses.first).to eq(nil)
      expect(acme.phone_number).to_not eq("(408) 555-1234")
      expect(acme.email).to_not eq("user@acme.com")
      signed_in_user :acme_root

      put :update, params: {
        id: acme.id.to_s,
        organization: {
          name: "ACME",
          phone_number: "(408) 555-1234",
          email: "user@acme.com",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          }
        }
      }

      acme.reload
      expect(acme.primary_address.to_s).to eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to eq("(408) 555-1234")
      expect(acme.email).to eq("user@acme.com")
    end

    it "is allowed for super admin" do
      expect(acme.addresses.first).to eq(nil)
      expect(acme.phone_number).to_not eq("(408) 555-1234")
      expect(acme.email).to_not eq("user@acme.com")
      signed_in_user :root

      put :update, params: {
        id: acme.id.to_s,
        organization: {
          name: "ACME Corp.",
          phone_number: "(408) 555-1234",
          email: "user@acme.com",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          },
          program_ids: [resource_closets.id]
        }
      }

      acme.reload
      expect(acme.primary_address.to_s).to eq("123 Main St, Campbell, CA")
      expect(acme.phone_number).to eq("(408) 555-1234")
      expect(acme.email).to eq("user@acme.com")
    end

    it "blocks changes to organization name for organization admin" do
      expect(acme.name).to eq("ACME")
      signed_in_user :acme_root

      put :update, params: {
        id: acme.id.to_s,
        organization: {
          name: "ACME Corp.",
          phone_number: "(408) 555-1234",
          email: "user@acme.com",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          }
        }
      }

      acme.reload
      expect(acme.name).to eq("ACME")
    end

    it "allows changes to organization name for super admin" do
      expect(acme.name).to eq("ACME")
      signed_in_user :root

      put :update, params: {
        id: acme.id.to_s,
        organization: {
          name: "ACME Corp.",
          phone_number: "(408) 555-1234",
          email: "user@acme.com",
          addresses_attributes: {
            "0" => { address: "123 Main St, Campbell, CA" }
          },
          program_ids: [resource_closets.id]
        }
      }

      acme.reload
      expect(acme.name).to eq("ACME Corp.")
    end
  end

  describe "DELETE destroy" do
    context "permissions" do
      it "is not allowed for any normal users" do
        expect do
          signed_in_user :acme_normal

          put :destroy, params: { id: acme.id.to_s }
        end.to raise_error(PermissionError)

        expect do
          signed_in_user :foo_inc_normal

          put :destroy, params: { id: acme.id.to_s }
        end.to raise_error(PermissionError)
      end

      it "is not allowed for any admin users" do
        expect do
          signed_in_user :acme_root

          put :destroy, params: { id: acme.id.to_s }
        end.to raise_error(PermissionError)

        expect do
          signed_in_user :foo_inc_root

          put :destroy, params: { id: acme.id.to_s }
        end.to raise_error(PermissionError)
      end

      it "is allowed for super admin" do
        expect(no_order_org.deleted_at).to eq(nil)

        signed_in_user :root

        put :destroy, params: { id: no_order_org.id.to_s }

        no_order_org.reload
        expect(no_order_org.deleted_at).not_to eq(nil)
      end
    end

    context "affiliated objects" do
      it "fails when there are existing open orders" do
        signed_in_user :root

        put :destroy, params: { id: open_order_org.id.to_s }

        open_order_org.reload
        expect(acme.deleted?).to eq(false)
      end

      it "succeeds when existing orders are rejected" do
        signed_in_user :root

        expect(rejected_order_org.deleted?).to eq(false)

        put :destroy, params: { id: rejected_order_org.id.to_s }

        rejected_order_org.reload
        expect(rejected_order_org.deleted?).to eq(true)
      end

      it "succeeds when existing orders are closed" do
        signed_in_user :root

        expect(closed_order_org.deleted?).to eq(false)

        put :destroy, params: { id: closed_order_org.id.to_s }

        closed_order_org.reload
        expect(closed_order_org.deleted?).to eq(true)
      end

      it "removes all organization_user records before deleting" do
        signed_in_user :root

        acme.open_orders.each do |order|
          order.update_status("close")
        end

        expect(acme.open_orders.count).to eq(0)
        expect(acme.organization_users.count).to eq(2)

        put :destroy, params: { id: acme.id.to_s }

        acme.reload
        expect(acme.organization_users.count).to eq(0)
      end
    end
  end
end

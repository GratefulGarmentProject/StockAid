require "rails_helper"

describe User, type: :model do
  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }

  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  describe "#organizations_with_admin_access" do
    it "returns all orgs for super admin" do
      expect(root.organizations_with_admin_access).to match_array(Organization.all)
    end

    it "returns orgs you have admin access for everyone else" do
      expect(acme_root.organizations_with_admin_access).to match_array(acme)
      expect(foo_inc_root.organizations_with_admin_access).to match_array(foo_inc)
    end
  end

  describe "#super_admin?" do
    it "tells if the user is an admin for all of the site" do
      expect(root).to be_a_super_admin

      expect(acme_root).to_not be_a_super_admin
      expect(acme_normal).to_not be_a_super_admin
    end
  end

  describe "#admin?" do
    it "tells if the user is an admin for a particular organization" do
      expect(root.admin?(acme)).to be_truthy
      expect(acme_root.admin?(acme)).to be_truthy
      expect(foo_inc_root.admin?(foo_inc)).to be_truthy

      expect(acme_normal.admin?(acme)).to be_falsey
      expect(acme_root.admin?(foo_inc)).to be_falsey
      expect(foo_inc_root.admin?(acme)).to be_falsey
    end
  end

  describe "#member?" do
    it "tells if the user is a member of a particular organization" do
      expect(acme_root.member?(acme)).to be_truthy
      expect(acme_normal.member?(acme)).to be_truthy
      expect(foo_inc_root.member?(foo_inc)).to be_truthy

      expect(root.member?(acme)).to be_falsey
      expect(root.member?(foo_inc)).to be_falsey
      expect(acme_root.member?(foo_inc)).to be_falsey
      expect(acme_normal.member?(foo_inc)).to be_falsey
      expect(foo_inc_root.member?(acme)).to be_falsey
    end
  end

  context "manipulating organizations" do
    describe "#create_organization" do
      it "is not allowed for non super users" do
        expect do
          acme_root.create_organization(params(organization: {
                                                 name: "Bar Corp.",
                                                 address: "123 Main St, Campbell, CA",
                                                 phone_number: "",
                                                 email: ""
                                               }))
        end.to raise_error(PermissionError)

        expect do
          acme_normal.create_organization(params(organization: {
                                                   name: "Bar Corp.",
                                                   address: "123 Main St, Campbell, CA",
                                                   phone_number: "",
                                                   email: ""
                                                 }))
        end.to raise_error(PermissionError)
      end

      it "can be missing email and phone_number" do
        root.create_organization(params(organization: {
                                          name: "Bar Corp.",
                                          address: "123 Main St, Campbell, CA",
                                          phone_number: "",
                                          email: ""
                                        }))
        org = Organization.find_by_name("Bar Corp.")
        expect(org).to be
        expect(org.name).to eq("Bar Corp.")
        expect(org.address).to eq("123 Main St, Campbell, CA")
        expect(org.phone_number).to be_blank
        expect(org.email).to be_blank
      end

      it "can include email and phone_number" do
        root.create_organization(params(organization: {
                                          name: "Bar Corp.",
                                          address: "123 Main St, Campbell, CA",
                                          phone_number: "(408) 555-5555",
                                          email: "bar@barcorp.com"
                                        }))
        org = Organization.find_by_name("Bar Corp.")
        expect(org).to be
        expect(org.name).to eq("Bar Corp.")
        expect(org.address).to eq("123 Main St, Campbell, CA")
        expect(org.phone_number).to eq("(408) 555-5555")
        expect(org.email).to eq("bar@barcorp.com")
      end
    end

    describe "#update_organization" do
      it "is not allowed for non-organization admin" do
        expect do
          acme_normal.update_organization(params(id: acme.id.to_s,
                                                 organization: {
                                                   name: "ACME Corp.",
                                                   address: "123 Main St, Campbell, CA",
                                                   phone_number: "",
                                                   email: ""
                                                 }))
        end.to raise_error(PermissionError)

        expect do
          foo_inc_root.update_organization(params(id: acme.id.to_s,
                                                  organization: {
                                                    name: "ACME Corp.",
                                                    address: "123 Main St, Campbell, CA",
                                                    phone_number: "",
                                                    email: ""
                                                  }))
        end.to raise_error(PermissionError)
      end

      it "is allowed for organization admin" do
        expect(acme.address).to_not eq("123 Main St, Campbell, CA")
        expect(acme.phone_number).to_not eq("(408) 555-1234")
        expect(acme.email).to_not eq("user@acme.com")
        acme_root.update_organization(params(id: acme.id.to_s,
                                             organization: {
                                               name: "ACME",
                                               address: "123 Main St, Campbell, CA",
                                               phone_number: "(408) 555-1234",
                                               email: "user@acme.com"
                                             }))
        acme.reload
        expect(acme.address).to eq("123 Main St, Campbell, CA")
        expect(acme.phone_number).to eq("(408) 555-1234")
        expect(acme.email).to eq("user@acme.com")
      end

      it "is allowed for super admin" do
        expect(acme.address).to_not eq("123 Main St, Campbell, CA")
        expect(acme.phone_number).to_not eq("(408) 555-1234")
        expect(acme.email).to_not eq("user@acme.com")
        root.update_organization(params(id: acme.id.to_s,
                                        organization: {
                                          name: "ACME Corp.",
                                          address: "123 Main St, Campbell, CA",
                                          phone_number: "(408) 555-1234",
                                          email: "user@acme.com"
                                        }))
        acme.reload
        expect(acme.address).to eq("123 Main St, Campbell, CA")
        expect(acme.phone_number).to eq("(408) 555-1234")
        expect(acme.email).to eq("user@acme.com")
      end

      it "blocks changes to organization name for organization admin" do
        expect(acme.name).to eq("ACME")
        acme_root.update_organization(params(id: acme.id.to_s,
                                             organization: {
                                               name: "ACME Corp.",
                                               address: "123 Main St, Campbell, CA",
                                               phone_number: "(408) 555-1234",
                                               email: "user@acme.com"
                                             }))
        acme.reload
        expect(acme.name).to eq("ACME")
      end

      it "allows changes to organization name for super admin" do
        expect(acme.name).to eq("ACME")
        root.update_organization(params(id: acme.id.to_s,
                                        organization: {
                                          name: "ACME Corp.",
                                          address: "123 Main St, Campbell, CA",
                                          phone_number: "(408) 555-1234",
                                          email: "user@acme.com"
                                        }))
        acme.reload
        expect(acme.name).to eq("ACME Corp.")
      end
    end
  end
end

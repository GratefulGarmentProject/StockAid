require "rails_helper"

describe User, type: :model do
  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }

  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

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
          acme_root.create_organization(name: "Bar Corp.",
                                        address: "123 Main St, Campbell, CA",
                                        phone_number: "",
                                        email: "")
        end.to raise_error(PermissionError)

        expect do
          acme_normal.create_organization(name: "Bar Corp.",
                                          address: "123 Main St, Campbell, CA",
                                          phone_number: "",
                                          email: "")
        end.to raise_error(PermissionError)
      end

      it "can be missing email and phone_number" do
        root.create_organization(name: "Bar Corp.",
                                 address: "123 Main St, Campbell, CA",
                                 phone_number: "",
                                 email: "")
        org = Organization.find_by_name("Bar Corp.")
        expect(org).to be
        expect(org.name).to eq("Bar Corp.")
        expect(org.address).to eq("123 Main St, Campbell, CA")
        expect(org.phone_number).to be_blank
        expect(org.email).to be_blank
      end

      it "can include email and phone_number" do
        root.create_organization(name: "Bar Corp.",
                                 address: "123 Main St, Campbell, CA",
                                 phone_number: "(408) 555-5555",
                                 email: "bar@barcorp.com")
        org = Organization.find_by_name("Bar Corp.")
        expect(org).to be
        expect(org.name).to eq("Bar Corp.")
        expect(org.address).to eq("123 Main St, Campbell, CA")
        expect(org.phone_number).to eq("(408) 555-5555")
        expect(org.email).to eq("bar@barcorp.com")
      end
    end
  end
end

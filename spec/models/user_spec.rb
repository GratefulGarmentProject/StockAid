require "rails_helper"

describe User, type: :model do
  let(:root) { users(:root) }
  let(:super_user) { users(:super_user) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }

  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  describe "#organizations_with_access" do
    it "returns all orgs for super admin" do
      expect(root.organizations_with_access).to match_array(Organization.all)
    end

    it "returns orgs you have access to for non super admins" do
      expect(acme_root.organizations_with_access).to match_array(acme)
      expect(acme_normal.organizations_with_access).to match_array(acme)
      expect(foo_inc_root.organizations_with_access).to match_array(foo_inc)
    end
  end

  describe "#root_admin?" do
    it "tells if the user is a root admin for all of the site" do
      expect(root).to be_a_root_admin
      expect(super_user).to_not be_a_root_admin

      expect(acme_root).to_not be_a_root_admin
      expect(acme_normal).to_not be_a_root_admin
    end
  end

  describe "#super_admin?" do
    it "tells if the user is an admin for all of the site" do
      expect(root).to be_a_super_admin
      expect(super_user).to be_a_super_admin

      expect(acme_root).to_not be_a_super_admin
      expect(acme_normal).to_not be_a_super_admin
    end
  end

  describe "#admin?" do
    it "tells if the user is an admin at any organization" do
      expect(root.admin?).to be_truthy
      expect(super_user.admin?).to be_truthy
      expect(acme_root.admin?).to be_truthy
      expect(foo_inc_root.admin?).to be_truthy

      expect(acme_normal.admin?).to be_falsey
    end
  end

  describe "#admin_at?" do
    it "tells if the user is an admin for a particular organization" do
      expect(root.admin_at?(acme)).to be_truthy
      expect(super_user.admin_at?(acme)).to be_truthy
      expect(acme_root.admin_at?(acme)).to be_truthy
      expect(foo_inc_root.admin_at?(foo_inc)).to be_truthy

      expect(acme_normal.admin_at?(acme)).to be_falsey
      expect(acme_root.admin_at?(foo_inc)).to be_falsey
      expect(foo_inc_root.admin_at?(acme)).to be_falsey
    end
  end

  describe "#member_at?" do
    it "tells if the user is a member of a particular organization" do
      expect(acme_root.member_at?(acme)).to be_truthy
      expect(acme_normal.member_at?(acme)).to be_truthy
      expect(foo_inc_root.member_at?(foo_inc)).to be_truthy

      expect(root.member_at?(acme)).to be_falsey
      expect(root.member_at?(foo_inc)).to be_falsey
      expect(super_user.member_at?(acme)).to be_falsey
      expect(super_user.member_at?(foo_inc)).to be_falsey
      expect(acme_root.member_at?(foo_inc)).to be_falsey
      expect(acme_normal.member_at?(foo_inc)).to be_falsey
      expect(foo_inc_root.member_at?(acme)).to be_falsey
    end
  end

  describe "#role_object" do
    it "allows comparing roles" do
      expect(root.role_object).to be > super_user.role_object
      expect(super_user.role_object).to be < root.role_object

      expect(root.role_object).to be > acme_root.role_object
      expect(acme_root.role_object).to be < root.role_object

      expect(super_user.role_object).to be > acme_root.role_object
      expect(acme_root.role_object).to be < super_user.role_object

      expect(super_user.role_object).to be == super_user.role_object
      expect(root.role_object).to be == root.role_object

      expect(super_user.role_object).to be <= super_user.role_object
      expect(root.role_object).to be >= root.role_object

      expect(acme_root.role_object).to be == acme_root.role_object
      expect(acme_root.role_object).to be == acme_normal.role_object

      expect(acme_root.role_object).to be <= acme_root.role_object
      expect(acme_root.role_object).to be >= acme_normal.role_object
    end
  end
end

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

  describe "#subscribed_to?" do
    it "returns false when not subscribed" do
      root.notification_subscriptions.destroy_all
      root.reload
      expect(root.subscribed_to?("spoilage")).to eq(false)
    end

    it "returns true when subscribed" do
      expect(root.subscribed_to?("spoilage")).to eq(true)
    end
  end

  describe "#update_subscriptions" do
    before { root.notification_subscriptions.destroy_all }

    it "subscribes when value is 'true'" do
      root.send(:update_subscriptions, spoilage: "true", deleted_donations: "false", deleted_purchases: "false")
      root.reload
      expect(root.subscribed_to?("spoilage")).to eq(true)
      expect(root.subscribed_to?("deleted_donations")).to eq(false)
    end

    it "unsubscribes existing subscription when value is 'false'" do
      root.send(:subscribe!, "spoilage")
      root.send(:update_subscriptions, spoilage: "false", deleted_donations: "false", deleted_purchases: "false")
      root.reload
      expect(root.subscribed_to?("spoilage")).to eq(false)
    end
  end

  describe "#can_subscribe_to_notifications?" do
    it "returns true only for root admin users" do
      expect(root.can_subscribe_to_notifications?).to eq(true)
      expect(super_user.can_subscribe_to_notifications?).to eq(false)
      expect(acme_root.can_subscribe_to_notifications?).to eq(false)
    end
  end

  describe "permission checks on concerns" do
    it "#can_destroy_purchase_shipments? returns true for super_admin" do
      expect(root.can_destroy_purchase_shipments?).to eq(true)
    end

    it "#can_delete_revenue_streams? returns true for super_admin" do
      expect(root.can_delete_revenue_streams?).to eq(true)
    end

    it "#can_force_password_reset_at? delegates to can_update_user_at?" do
      expect(root.can_force_password_reset_at?(organizations(:acme))).to eq(true)
    end

    it "#can_delete_closed_donation? checks all conditions" do
      closed_donation = donations(:fully_synced_donation)
      expect(root.can_delete_closed_donation?(closed_donation)).to be_in([true, false])
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

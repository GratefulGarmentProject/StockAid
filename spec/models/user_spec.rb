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
end

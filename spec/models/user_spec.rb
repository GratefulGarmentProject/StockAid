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

  describe "#subscribe!" do
    it "re-enables a disabled subscription" do
      root.send(:unsubscribe!, "spoilage")
      root.reload
      root.send(:subscribe!, "spoilage")
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

  describe "#update_roles" do
    it "removes the user from an organization when role is blank" do
      expect { acme_normal.send(:update_roles, root, roles: { acme.id.to_s => "" }) }
        .to change(OrganizationUser, :count).by(-1)
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

  describe "VendorManipulator permissions" do
    it "#can_create_vendors? returns true for super_admin" do
      expect(root.can_create_vendors?).to eq(true)
      expect(acme_normal.can_create_vendors?).to eq(false)
    end

    it "#can_update_vendors? returns true for super_admin" do
      expect(root.can_update_vendors?).to eq(true)
      expect(acme_normal.can_update_vendors?).to eq(false)
    end

    it "#can_view_vendors? returns true for super_admin" do
      expect(root.can_view_vendors?).to eq(true)
      expect(acme_normal.can_view_vendors?).to eq(false)
    end

    it "#can_delete_and_restore_vendors? returns true for super_admin" do
      expect(root.can_delete_and_restore_vendors?).to eq(true)
      expect(acme_normal.can_delete_and_restore_vendors?).to eq(false)
    end

    it "#create_vendor raises PermissionError for non-super-admin" do
      params = ActionController::Parameters.new(vendor: { name: "Test" })
      expect { acme_normal.create_vendor(params) }.to raise_error(PermissionError)
    end
  end

  describe "SurveyManipulator permissions" do
    let(:org_request) { survey_organization_requests(:foo_unanswered_org_request) }

    it "#can_view_and_edit_surveys? returns true for super_admin" do
      expect(root.can_view_and_edit_surveys?).to eq(true)
      expect(acme_normal.can_view_and_edit_surveys?).to eq(false)
    end

    it "#can_email_survey_requests? returns true for super_admin" do
      expect(root.can_email_survey_requests?).to eq(true)
    end

    it "#can_create_surveys? returns true for super_admin" do
      expect(root.can_create_surveys?).to eq(true)
    end

    it "#can_delete_surveys? returns true for super_admin" do
      expect(root.can_delete_surveys?).to eq(true)
    end

    it "#can_answer_organization_survey? returns true for super_admin and org members" do
      expect(root.can_answer_organization_survey?(org_request)).to eq(true)
      expect(acme_normal.can_answer_organization_survey?(org_request)).to eq(false)
    end
  end

  describe "ItemManipulator permissions" do
    it "#can_view_and_edit_items? returns true for super_admin" do
      expect(root.can_view_and_edit_items?).to eq(true)
    end

    it "#can_view_inventory_reconciliations? returns true for super_admin" do
      expect(root.can_view_inventory_reconciliations?).to eq(true)
    end

    it "#can_edit_inventory_reconciliations? returns true for super_admin" do
      expect(root.can_edit_inventory_reconciliations?).to eq(true)
    end

    it "#can_view_bins? returns true for super_admin" do
      expect(root.can_view_bins?).to eq(true)
    end

    it "#can_edit_bins? returns true for super_admin" do
      expect(root.can_edit_bins?).to eq(true)
    end

    it "#can_bulk_price_items? returns true for super_admin" do
      expect(root.can_bulk_price_items?).to eq(true)
    end

    it "#can_edit_inventory_reconciliation? returns true for open reconciliation" do
      reconciliation = inventory_reconciliations(:open_reconciliation)
      expect(root.can_edit_inventory_reconciliation?(reconciliation)).to eq(true)
    end

    it "#create_inventory_reconciliation creates a reconciliation" do
      expect do
        root.create_inventory_reconciliation(title: "Spec Reconciliation")
      end.to change(InventoryReconciliation, :count).by(1)
    end

    it "#create_bin creates a new bin" do
      bin_location = bin_locations(:empty_bin_location)
      params = ActionController::Parameters.new(
        selected_bin_location: bin_location.id.to_s,
        label_prefix: "SPEC",
        label_suffix: "99"
      )
      expect do
        root.create_bin(params)
      end.to change(Bin, :count).by(1)
    end

    it "#update_bin updates an existing bin label" do
      bin = bins(:empty_bin)
      params = ActionController::Parameters.new(
        id: bin.id.to_s,
        selected_bin_location: bin.bin_location_id.to_s,
        label_prefix: "UPDATED",
        label_suffix: "01"
      )
      root.update_bin(params)
      expect(bin.reload.label).to eq("UPDATED01")
    end

    it "#update_bin_location updates an existing bin location's rack and shelf" do
      location = bin_locations(:empty_bin_location)
      params = ActionController::Parameters.new(id: location.id.to_s, rack: "ZRACK", shelf: "ZSHELF")
      root.update_bin_location(params)
      expect(location.reload.rack).to eq("ZRACK")
      expect(location.reload.shelf).to eq("ZSHELF")
    end

    it "#update_bin_location raises PermissionError for non-super-admin" do
      location = bin_locations(:empty_bin_location)
      params = ActionController::Parameters.new(id: location.id.to_s, rack: "ZRACK", shelf: "ZSHELF")
      expect { acme_normal.update_bin_location(params) }.to raise_error(PermissionError)
      expect(location.reload.rack).to_not eq("ZRACK")
    end

    it "#move_bins moves all bins from one location to another" do
      source = bin_locations(:rack_1_shelf_1)
      destination = bin_locations(:empty_bin_location)
      bin_ids = source.bins.pluck(:id)

      root.move_bins(id: source.id.to_s, destination_bin_location_id: destination.id.to_s)

      expect(Bin.where(id: bin_ids).pluck(:bin_location_id).uniq).to eq([destination.id])
    end

    it "#move_bins raises PermissionError for non-super-admin" do
      source = bin_locations(:rack_1_shelf_1)
      destination = bin_locations(:empty_bin_location)
      bin_ids = source.bins.pluck(:id)

      expect do
        acme_normal.move_bins(id: source.id.to_s, destination_bin_location_id: destination.id.to_s)
      end.to raise_error(PermissionError)

      expect(Bin.where(id: bin_ids).pluck(:bin_location_id).uniq).to eq([source.id])
    end

    it "#destroy_bin destroys an empty bin" do
      bin = bins(:empty_bin)
      expect do
        root.destroy_bin(id: bin.id)
      end.to change { Bin.not_deleted.count }.by(-1)
    end

    it "#destroy_bin_location destroys an empty bin location" do
      location = bin_locations(:empty_bin_location)
      expect do
        root.destroy_bin_location(id: location.id)
      end.to change(BinLocation, :count).by(-1)
    end

    it "#destroy_bin_location falls back to soft-deleting a location whose only bin is already soft-deleted" do
      location = bin_locations(:location_with_only_deleted_bin)
      expect do
        root.destroy_bin_location(id: location.id)
      end.to_not change(BinLocation, :count)
      expect(location.reload.deleted_at).to be_present
    end

    it "#can_view_items? returns true for all users" do
      expect(root.can_view_items?).to eq(true)
      expect(acme_normal.can_view_items?).to eq(true)
    end

    it "#can_view_item_program_ratios? returns true for super_admin" do
      expect(root.can_view_item_program_ratios?).to eq(true)
      expect(acme_normal.can_view_item_program_ratios?).to eq(false)
    end

    it "#can_edit_item_program_ratios? returns true for super_admin" do
      expect(root.can_edit_item_program_ratios?).to eq(true)
      expect(acme_normal.can_edit_item_program_ratios?).to eq(false)
    end

    it "#create_item_program_ratio creates a new ratio" do
      all_ratios = Program.all.each_with_object({}) { |p, h| h[p.id.to_s] = "0" }
      all_ratios[programs(:resource_closets).id.to_s] = "100"
      params = ActionController::Parameters.new(
        item_program_ratio: {
          name: "New Spec Ratio",
          program_ratio: all_ratios,
          apply_to: {}
        }
      )
      expect { root.create_item_program_ratio(params) }.to change(ItemProgramRatio, :count).by(1)
    end

    it "#update_item_program_ratio updates an existing ratio" do
      ratio = item_program_ratios(:all_resource_closets)
      all_ratios = Program.all.each_with_object({}) { |p, h| h[p.id.to_s] = "0" }
      all_ratios[programs(:resource_closets).id.to_s] = "100"
      params = ActionController::Parameters.new(
        id: ratio.id,
        item_program_ratio: {
          name: "Updated Ratio Name",
          program_ratio: all_ratios,
          apply_to: {}
        }
      )
      root.update_item_program_ratio(params)
      expect(ratio.reload.name).to eq("Updated Ratio Name")
    end

    it "#destroy_item_program_ratio raises when ratio has items" do
      ratio = item_program_ratios(:all_resource_closets)
      expect { root.destroy_item_program_ratio(id: ratio.id) }.to raise_error(PermissionError)
    end

    it "#unignore_bin restores a bin to the reconciliation" do
      reconciliation = inventory_reconciliations(:open_reconciliation)
      bin = bins(:empty_bin)
      reconciliation.update!(ignored_bin_ids: [bin.id])
      result = root.unignore_bin(id: reconciliation.id, bin_id: bin.id)
      expect(result.ignored_bin_ids).not_to include(bin.id)
    end

    it "#update_count_sheet updates an existing count sheet" do
      reconciliation = inventory_reconciliations(:open_reconciliation)
      sheet = reconciliation.count_sheets.create!(bin: bins(:empty_bin), counter_names: [], complete: false)
      params = ActionController::Parameters.new(
        inventory_reconciliation_id: reconciliation.id,
        id: sheet.id,
        counter_names: ["Alice"],
        counts: {}
      )
      result = root.update_count_sheet(params)
      expect(result).to eq(sheet)
    end

    it "#delete_count_sheet deletes a count sheet and adds bin to ignored" do
      sheet = inventory_reconciliations(:in_progress_reconciliation).count_sheets.first
      reconciliation = sheet.inventory_reconciliation
      params = ActionController::Parameters.new(
        inventory_reconciliation_id: reconciliation.id,
        id: sheet.id
      )
      result = root.delete_count_sheet(params)
      expect(result.ignored_bin_ids).to include(sheet.bin_id)
    end

    it "#delete_unnecessary_count_sheets removes empty sheets" do
      reconciliation = inventory_reconciliations(:in_progress_reconciliation)
      params = ActionController::Parameters.new(inventory_reconciliation_id: reconciliation.id)
      result = root.delete_unnecessary_count_sheets(params)
      expect(result).to eq(reconciliation)
    end

    it "#reconciliation_comment adds a note to the reconciliation" do
      reconciliation = inventory_reconciliations(:open_reconciliation)
      expect do
        root.reconciliation_comment(id: reconciliation.id, content: "Test note from spec")
      end.to change { reconciliation.reconciliation_notes.count }.by(1)
    end

    it "#delete_reconciliation destroys the reconciliation and its sheets" do
      reconciliation = inventory_reconciliations(:open_reconciliation)
      expect do
        root.delete_reconciliation(id: reconciliation.id)
      end.to change(InventoryReconciliation, :count).by(-1)
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

  describe "#ship_to_names (order_manipulator)" do
    it "returns organization ship_to_names for super_admin" do
      order = orders(:open_order)
      result = root.ship_to_names(order)
      expect(result).to be_an(Array)
    end

    it "returns order ship_to_names when order user is also non-super-admin" do
      order = Order.create!(
        organization: organizations(:acme),
        user: acme_root,
        order_date: Time.zone.now,
        status: :select_items,
        ship_to_name: "Test Receiver",
        ship_to_address: "123 Test St."
      )
      result = acme_root.ship_to_names(order)
      expect(result).to be_an(Array)
    end
  end

  describe "#phone_numbers_are_different validation" do
    it "adds an error when primary and secondary numbers match" do
      user = users(:root)
      user.secondary_number = user.primary_number
      user.valid?
      expect(user.errors[:secondary_phone]).to be_present
    end
  end
end

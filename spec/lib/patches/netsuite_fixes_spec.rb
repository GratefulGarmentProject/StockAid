require "rails_helper"

describe "netsuite monkeypatches" do
  context "without patch" do
    before do
      class NetSuite::Records::CustomFieldList # rubocop:disable Style/ClassAndModuleChildren
        # Undo the monkeypatch so we can test whether it is still needed
        alias extract_custom_field __extract_custom_field_without_multiselect_fix
      end
    end

    after do
      class NetSuite::Records::CustomFieldList # rubocop:disable Style/ClassAndModuleChildren
        # Restore the monkeypatch after
        alias extract_custom_field __extract_custom_field_with_multiselect_fix
      end
    end

    # -------------------------
    # ---       NOTE       ----
    # -------------------------
    #
    # IF this test fails after a netsuite gem upgrade, it may mean you can
    # remove the multiselect custom field fix in lib/patches/netsuite_fixes.rb
    #
    # PLEASE run the test below this one after removing the patch to make sure
    # the bug is fully fixed in the same way the patch is fixing it.
    it "is still broken for multi select custom fields" do
      list = NetSuite::Records::CustomFieldList.new(
        custom_field: [
          {
            script_id: "custom_multi_select_field",
            type: "platformCore:MultiSelectCustomFieldRef",
            value: {
              name: "The Answer",
              internal_id: 42,
              type_id: 142
            }
          }
        ]
      )

      expect(list.custom_multi_select_field).to_not be_nil
      expect(list.custom_multi_select_field.value.first.name).to_not eq("The Answer")
      expect(list.custom_multi_select_field.value.size).to eq(3)
    end
  end

  it "is fixed with the patch" do
    list = NetSuite::Records::CustomFieldList.new(
      custom_field: [
        {
          script_id: "custom_multi_select_field",
          type: "platformCore:MultiSelectCustomFieldRef",
          value: {
            name: "The Answer",
            internal_id: 42,
            type_id: 142
          }
        }
      ]
    )

    expect(list.custom_multi_select_field).to_not be_nil
    expect(list.custom_multi_select_field.value.first.name).to eq("The Answer")
  end
end

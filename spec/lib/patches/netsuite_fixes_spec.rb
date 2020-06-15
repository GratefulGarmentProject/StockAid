require "rails_helper"

describe "netsuite monkeypatches" do
  context "without patch" do
    before do
      class NetSuite::Records::CustomFieldList
        # Undo the monkeypatch so we can test whether it is still needed
        alias_method :extract_custom_field, :__extract_custom_field_without_multiselect_fix
      end
    end

    after do
      class NetSuite::Records::CustomFieldList
        # Restore the monkeypatch after
        alias_method :extract_custom_field, :__extract_custom_field_with_multiselect_fix
      end
    end

    it "is still broken for multi select custom fields" do
      list = NetSuite::Records::CustomFieldList.new({
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
      })

      expect(list.custom_multi_select_field).to_not be_nil
      expect(list.custom_multi_select_field.value.first.name).to_not eq("The Answer")
      expect(list.custom_multi_select_field.value.size).to eq(3)
    end
  end

  it "is fixed with the patch" do
    list = NetSuite::Records::CustomFieldList.new({
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
    })

    expect(list.custom_multi_select_field).to_not be_nil
    expect(list.custom_multi_select_field.value.first.name).to eq("The Answer")
  end
end

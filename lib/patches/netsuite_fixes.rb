module NetSuite
  module Records
    class CustomFieldList
      private

      def __extract_custom_field_with_multiselect_fix(custom_field_data)
        if custom_field_data.is_a?(CustomField)
          custom_fields << custom_field_data
        else
          attrs = custom_field_data.clone
          type = (custom_field_data[:"@xsi:type"] || custom_field_data[:type])

          if type == "platformCore:SelectCustomFieldRef"
            attrs[:value] = CustomRecordRef.new(custom_field_data[:value])
          elsif type == "platformCore:MultiSelectCustomFieldRef" && !custom_field_data[:value].is_a?(Array)
            attrs[:value] = [CustomRecordRef.new(custom_field_data[:value])]
          elsif type == "platformCore:MultiSelectCustomFieldRef"
            attrs[:value] = custom_field_data[:value].map do |entry|
              CustomRecordRef.new(entry)
            end
          end

          custom_fields << CustomField.new(attrs)
        end
      end

      alias_method :__extract_custom_field_without_multiselect_fix, :extract_custom_field
      alias_method :extract_custom_field, :__extract_custom_field_with_multiselect_fix
    end
  end
end

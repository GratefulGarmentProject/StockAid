module ItemsHelper
  def item_history_info(version) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    parameters = {
      details: version.edit_source,
      amount: version.edit_amount
    }

    if version.changeset["current_quantity"]
      parameters[:previous_total] = version.changeset["current_quantity"].first
      parameters[:new_total] = version.changeset["current_quantity"].last
      parameters[:amount_description] = t(version.edit_method, **parameters.merge(scope: %i[history item method]))
      parameters[:reason] = t(version.edit_reason, **parameters.merge(scope: %i[history item reason]))
    elsif version.edit_reason == "bulk_pricing_change" || version.changeset["value"]
      previous_price = number_to_currency(version.changeset["value"].first)
      new_price = number_to_currency(version.changeset["value"].last)
      parameters[:amount_description] = "Updated from #{previous_price} to #{new_price}"
      parameters[:reason] =
        if version.edit_reason == "bulk_pricing_change"
          "Bulk pricing change"
        else
          "Price change"
        end
      parameters[:details] ||= "n/a"
      parameters[:new_total] = 0 if version.event == "create"
    else
      raise "Version history info cannot be determined: #{version.id}"
    end

    t(version.event, **parameters.merge(scope: %i[history item event]))
  end

  def new_item_with_category_path
    if @category
      new_item_path(category_id: @category.id)
    else
      new_item_path
    end
  end

  def cancel_new_item_path
    if @item.category
      items_path(category_id: @item.category.id)
    else
      items_path
    end
  end
end

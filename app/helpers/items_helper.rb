module ItemsHelper
  def user_name(value)
    return "System" unless value
    User.find(value).name
  end

  def item_history_info(version)
    parameters = build_history_parameters(version)
    t(version.event, parameters.merge(scope: %i[history item event]))
  end

  def build_history_parameters(version)
    parameters = {
      details: version.edit_source,
      amount: version.edit_amount,
      previous_total: version.changeset["current_quantity"].first,
      new_total: version.changeset["current_quantity"].last
    }

    parameters[:amount_description] = t(version.edit_method, parameters.merge(scope: %i[history item method]))
    parameters[:reason] = t(version.edit_reason, parameters.merge(scope: %i[history item reason]))
    parameters
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

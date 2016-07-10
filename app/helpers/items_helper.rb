module ItemsHelper
  def user_name(value)
    return "System" unless value
    User.find(value).name
  end

  def version_details(version)
    parameters = {
      details: version.edit_source,
      amount: version.edit_amount,
      previous_total: version.changeset["current_quantity"].first,
      new_total: version.changeset["current_quantity"].last
    }

    parameters[:amount_description] = t(version.edit_method, parameters.merge(scope: [:history, :item, :method]))
    parameters[:reason] = t(version.edit_reason, parameters.merge(scope: [:history, :item, :reason]))
    t(version.event, parameters.merge(scope: [:history, :item, :event]))
  end
end

module OrganizationsHelper
  def cancel_edit_organization_path
    Redirect.to(organizations_path, params, allow: %i[order users])
  end
end

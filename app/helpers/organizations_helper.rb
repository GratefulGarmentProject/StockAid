module OrganizationsHelper
  def cancel_edit_organization_path
    Redirect.to(organizations_path, params, allow: [:order, :users, :user])
  end
end

module UsersHelper
  def additional_organizations_json(user, organizations)
    organizations.drop(1).map do |organization|
      {
        name: organization.name,
        role: t(user.role_at(organization), scope: "role.organization"),
        href: edit_organization_path(organization, redirect_to: "users")
      }
    end.to_json
  end

  def cancel_edit_user_path
    Redirect.to(users_path, params, allow: :order)
  end
end

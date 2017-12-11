class AddressChangeMailer < ActionMailer::Base
  layout 'admin_mailer_large'

  def change(organization, before, after)
    @organization = organization
    @before = before
    @after = after

    all_admins_sql = user.include(:organization_users).join(organization_users, Arel::Nodes::OuterJoin).on(users[:id].eq(organization_users[:user_id])).where(sys_admins.or(org_admins)).to_sql

    admins = User.includes(:organization_users).find_by_sql(all_admins_sql)

    admins.each do |admin|
      mail to: admin.email, subject: "Address change for #{@organization.name}"
    end
  end

  private

  def user
    User.arel_table
  end

  def organization_users
    OrganizationUser.arel_table
  end

  def sys_admins
    user[:role].eq('admin')
  end

  def org_admins
    organization_users[:organization].eq(@organization)
      .and(organization_users[:role].eq('admin'))
  end
end

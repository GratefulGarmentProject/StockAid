class Redirect
  class MissingIdError < StandardError; end
  class NotAllowedError < StandardError; end
  class NotImplimentedError < StandardError; end

  def self.to(default, params, allow: [])
    return default if params[:redirect_to].blank?
    allow = [allow].flatten.map(&:to_s)
    raise NotAllowedError if allow.exclude?(params[:redirect_to])

    path_for(params)
  end

  private_class_method def self.path_for(params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Layout/LineLength, Metrics/MethodLength
    case params[:redirect_to]
    when "category"
      Rails.application.routes.url_helpers.edit_item_path(category_id: id_from(params))
    when "inventory"
      Rails.application.routes.url_helpers.items_path
    when "new_purchase"
      Rails.application.routes.url_helpers.new_purchase_path
    when "organization"
      Rails.application.routes.url_helpers.edit_organization_path(id_from(params))
    when "organizations"
      Rails.application.routes.url_helpers.organizations_path
    when "organizations_deleted"
      Rails.application.routes.url_helpers.deleted_organizations_path
    when "order"
      Rails.application.routes.url_helpers.edit_order_path(id_from(params))
    when "orders"
      Rails.application.routes.url_helpers.orders_path
    when "survey_request"
      Rails.application.routes.url_helpers.survey_request_path(id_from(params))
    when "user"
      Rails.application.routes.url_helpers.edit_user_path(id_from(params))
    when "users"
      Rails.application.routes.url_helpers.users_path
    when "vendor"
      Rails.application.routes.url_helpers.edit_vendor_path(id_from(params))
    when "vendors"
      Rails.application.routes.url_helpers.vendors_path
    else
      raise NotImplimentedError
    end
  end

  private_class_method def self.id_from(params)
    raise MissingIdError if params[:redirect_id].blank?
    params[:redirect_id].to_i
  end
end

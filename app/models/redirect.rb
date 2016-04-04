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

  private_class_method def self.path_for(params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/LineLength
    case params[:redirect_to]
    when "orders"
      orders_path
    when "order"
      edit_order_path(id_from(params))
    when "inventory"
      items_path
    when "category"
      edit_item_path(category_id: id_from(params))
    when "organizations"
      organizations_path
    when "organization"
      edit_organization_path(id_from(params))
    when "users"
      users_path
    when "user"
      edit_user_path(id_from(params))
    else
      raise NotImplimentedError
    end
  end

  private_class_method def self.id_from(params)
    raise MissingIdError if params[:redirect_id].blank?
    params[:redirect_id].to_i
  end

  private_class_method def self.orders_path
    Rails.application.routes.url_helpers.orders_path
  end

  private_class_method def self.edit_order_path(id)
    Rails.application.routes.url_helpers.edit_order_path(id)
  end

  private_class_method def self.items_path
    Rails.application.routes.url_helpers.items_path
  end

  private_class_method def self.edit_item_path(id)
    Rails.application.routes.url_helpers.edit_item_path(category_id: id)
  end

  private_class_method def self.organizations_path
    Rails.application.routes.url_helpers.organizations_path
  end

  private_class_method def self.edit_organization_path(id)
    Rails.application.routes.url_helpers.edit_organization_path(id)
  end

  private_class_method def self.users_path
    Rails.application.routes.url_helpers.users_path
  end

  private_class_method def self.edit_user_path(id)
    Rails.application.routes.url_helpers.edit_user_path(id)
  end
end

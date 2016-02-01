class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private_class_method def self.active_tab(tab, *options)
    before_action(*options) { @active_tab = tab }
  end

  private_class_method def self.require_permission(permission_options, *options)
    before_action(*options) { PermissionError.check(current_user, permission_options) }
  end
end

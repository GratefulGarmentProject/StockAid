class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  private_class_method def self.active_tab(tab, *options)
    before_action(*options) { @active_tab = tab }
  end

  def require_permission(options)
    PermissionError.check(current_user, options)
  end
end

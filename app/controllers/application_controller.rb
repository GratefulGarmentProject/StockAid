class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_profiler_access

  protected

  def show_detailed_exceptions?
    current_user.show_detailed_exceptions? if current_user
  end

  private

  def user_for_paper_trail
    super || "Unknown"
  end

  def set_profiler_access
    if current_user && current_user.can_view_profiler_results? && Profiler.enabled?(session)
      Rack::MiniProfiler.authorize_request
    else
      Rack::MiniProfiler.deauthorize_request
    end
  end

  private_class_method def self.no_login(*options)
    skip_before_action :authenticate_user!, *options
  end

  private_class_method def self.active_tab(tab, *options)
    before_action(*options) { @active_tab = tab }
  end

  private_class_method def self.require_permission(permission_options, *options)
    before_action(*options) { PermissionError.check(current_user, permission_options) }
  end
end

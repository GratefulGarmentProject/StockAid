class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate_user!
  before_action :set_profiler_access
  before_action :set_paper_trail_whodunnit

  protected

  def show_detailed_exceptions?
    current_user&.show_detailed_exceptions?
  end

  private

  def send_csv(object, options)
    headers["X-Accel-Buffering"] = "no"
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "text/csv; charset=utf-8"
    headers["Content-Disposition"] = %(attachment; filename="#{options[:filename]}")
    headers["Last-Modified"] = Time.zone.now.ctime.to_s

    self.response_body = Enumerator.new do |enum|
      object.to_csv(enum)
    end
  end

  def user_for_paper_trail
    super || "Unknown"
  end

  def set_profiler_access
    if current_user&.can_view_profiler_results? && Profiler.enabled?(session)
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

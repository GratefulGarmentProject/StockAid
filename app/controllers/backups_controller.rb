class BackupsController < ApplicationController
  include ActionController::Live
  require_permission :can_backup?

  def show
    backup = Backup.new
    return redirect_to :root, flash: { error: backup.error_message } if backup.error?
    response.headers["Content-Type"] = "application/octet-stream"
    response.headers["Content-Disposition"] = %(attachment; filename="#{backup.filename}")
    backup.stream_response(response)
  ensure
    backup.close
  end
end

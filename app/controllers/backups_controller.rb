class BackupsController < ApplicationController
  include ActionController::Live
  require_permission :can_backup?

  def show
    backup = Backup.new
    response.headers["Content-Type"] = "application/octet-stream"
    response.headers["Content-Disposition"] = %(attachment; filename="#{backup.filename}")
    backup.stream(response.stream)
  ensure
    response.stream.close
  end
end

class BackupsController < ApplicationController
  include ActionController::Live
  require_permission :can_backup?

  def show
    Backup.new do |backup|
      return redirect_to :root, flash: { error: backup.error_message } if backup.error?
      response.headers["Content-Type"] = "application/octet-stream"
      response.headers["Content-Disposition"] = %(attachment; filename="#{backup.filename}")
      backup.stream_response(response)
    end
  end
end

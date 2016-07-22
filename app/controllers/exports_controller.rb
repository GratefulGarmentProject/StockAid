class ExportsController < ApplicationController
  include ActionController::Live
  require_permission :can_export?

  def show
    Export.new do |export|
      response.headers["Content-Type"] = "application/octet-stream"
      response.headers["Content-Disposition"] = %(attachment; filename="#{export.filename}")
      export.stream_response(response)
    end
    return redirect_to :root
  end
end

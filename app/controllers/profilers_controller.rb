class ProfilersController < ApplicationController
  require_permission :can_view_profiler_results?

  def toggle
    state = Profiler.toggle(session)
    redirect_to :root, flash: { success: "Profiling turned #{state}" }
  end
end

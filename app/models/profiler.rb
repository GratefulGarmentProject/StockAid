class Profiler
  def self.enabled?(session)
    session[:profiler_enabled] == "true"
  end

  def self.toggle_label(session)
    if enabled?(session)
      "Turn Off Profiling"
    else
      "Turn On Profiling"
    end
  end

  def self.toggle(session)
    if enabled?(session)
      session[:profiler_enabled] = "false"
      "off"
    else
      session[:profiler_enabled] = "true"
      "on"
    end
  end
end

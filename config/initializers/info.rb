Rails.application.config.version =
  if Rails.env.development?
    `git rev-parse HEAD`.strip
  else
    ENV.fetch("SOURCE_VERSION", "unknown")
  end

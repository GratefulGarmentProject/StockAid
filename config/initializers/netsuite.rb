def common_netsuite_config(config)
  config.reset!

  config.account ENV["STOCKAID_NETSUITE_ACCOUNT_ID"]
  config.api_version ENV.fetch("STOCKAID_NETSUITE_API_VERSION", "2018_2")
  config.read_timeout ENV.fetch("STOCKAID_NETSUITE_READ_TIMEOUT", 60).to_i
  config.wsdl_domain NetSuite::Utilities.data_center_url(ENV["STOCKAID_NETSUITE_ACCOUNT_ID"]).sub(%r{\A\w+://}, "")
end

if Rails.env.test?
  Rails.logger.warn "Skipping NetSuite configuration"
elsif ENV["STOCKAID_NETSUITE_INTEGRATION"] == "DISABLED"
  Rails.logger.warn "NetSuite configuration is disabled"
  Rails.application.config.netsuite_initialized = false
elsif %w[
  STOCKAID_NETSUITE_ACCOUNT_ID
  STOCKAID_NETSUITE_APPLICATION_ID
  STOCKAID_NETSUITE_CONSUMER_KEY
  STOCKAID_NETSUITE_CONSUMER_SECRET
  STOCKAID_NETSUITE_TOKEN_ID
  STOCKAID_NETSUITE_TOKEN_SECRET
].all? { |x| ENV[x].present? }
  NetSuite.configure do
    common_netsuite_config(self)

    consumer_key     ENV["STOCKAID_NETSUITE_CONSUMER_KEY"]
    consumer_secret  ENV["STOCKAID_NETSUITE_CONSUMER_SECRET"]
    token_id         ENV["STOCKAID_NETSUITE_TOKEN_ID"]
    token_secret     ENV["STOCKAID_NETSUITE_TOKEN_SECRET"]
  end

  Rails.logger.info "Initialized NetSuite integration with token authentication"
  Rails.application.config.netsuite_initialized = true
elsif %w[
  STOCKAID_NETSUITE_ACCOUNT_ID
  STOCKAID_NETSUITE_APPLICATION_ID
  STOCKAID_NETSUITE_EMAIL
  STOCKAID_NETSUITE_PASSWORD
  STOCKAID_NETSUITE_ROLE
].all? { |x| ENV[x].present? }
  NetSuite.configure do
    common_netsuite_config(self)

    email     ENV["STOCKAID_NETSUITE_EMAIL"]
    password  ENV["STOCKAID_NETSUITE_PASSWORD"]
    role      ENV["STOCKAID_NETSUITE_ROLE"].to_i

    self.soap_header = {
      "platformMsgs:ApplicationInfo" => {
        "platformMsgs:applicationId" => ENV["STOCKAID_NETSUITE_APPLICATION_ID"]
      }
    }
  end

  Rails.logger.info "Initialized NetSuite integration with password authentication"

  if Rails.env.production?
    Rails.logger.warn "Please switch NetSuite integration to token based authenticiation"
  end

  Rails.application.config.netsuite_initialized = true
else
  Rails.logger.warn "NetSuite integration is not initialized"
  Rails.application.config.netsuite_initialized = false
end

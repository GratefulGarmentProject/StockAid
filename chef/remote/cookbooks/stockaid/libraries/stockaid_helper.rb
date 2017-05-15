module StockAid
  module Helper
    module_function def stockaid_environment(node)
      database_password_file = File.join(node[:stockaid][:dir], ".stockaid-db-password")
      database_password = File.read(database_password_file).strip
      secret_key_base_file = File.join(node[:stockaid][:dir], ".stockaid-secret-key-base")
      secret_key_base = File.read(secret_key_base_file)
      devise_pepper_file = File.join(node[:stockaid][:dir], ".stockaid-devise-pepper")
      devise_pepper = File.read(devise_pepper_file)

      {}.tap do |environment|
        environment.merge!(
          "STOCKAID_DATABASE_HOST" => "localhost",
          "STOCKAID_DATABASE_USERNAME" => "stockaid",
          "STOCKAID_DATABASE_PASSWORD" => database_password,
          "STOCKAID_SECRET_KEY_BASE" => secret_key_base,
          "STOCKAID_DEVISE_PEPPER" => devise_pepper,
          "STOCKAID_ENV_SETUP" => "3",
          "STOCKAID_SITE_NAME" => node[:stockaid][:site_name],
          "STOCKAID_ACTION_MAILER_DEFAULT_FROM" => node[:stockaid][:mailer][:default_from],
          "STOCKAID_ACTION_MAILER_DEFAULT_HOST" => node[:stockaid][:mailer][:default_host]
        )

        if node[:stockaid][:google][:api_key]
          environment["STOCKAID_GOOGLE_API_KEY"] = node[:stockaid][:google][:api_key]
        end

        if node[:stockaid][:google][:drive_json]
          require "json"
          environment["STOCKAID_GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON"] = node[:stockaid][:google][:drive_json].to_json
        end

        if node[:stockaid][:mailgun][:enabled]
          environment["STOCKAID_MAILGUN_DOMAIN"] = node[:stockaid][:mailgun][:domain]
          environment["STOCKAID_MAILGUN_API_KEY"] = node[:stockaid][:mailgun][:api_key]
        end

        if node[:stockaid][:newrelic][:enabled]
          environment["NEW_RELIC_APP_NAME"] = node[:stockaid][:newrelic][:app_name]
          environment["NEW_RELIC_LICENSE_KEY"] = node[:stockaid][:newrelic][:license_key]
        end

        environment
      end
    end
  end
end

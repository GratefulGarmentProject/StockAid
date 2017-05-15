require "json"

module StockAid
  class Environment
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def to_h
      simple_env.merge(google_env).merge(mailgun_env).merge(newrelic_env)
    end

    private

    def simple_env
      {
        "STOCKAID_DATABASE_HOST" => "localhost",
        "STOCKAID_DATABASE_USERNAME" => "stockaid",
        "STOCKAID_DATABASE_PASSWORD" => database_password,
        "STOCKAID_SECRET_KEY_BASE" => secret_key_base,
        "STOCKAID_DEVISE_PEPPER" => devise_pepper,
        "STOCKAID_ENV_SETUP" => "3",
        "STOCKAID_SITE_NAME" => node[:stockaid][:site_name],
        "STOCKAID_ACTION_MAILER_DEFAULT_FROM" => node[:stockaid][:mailer][:default_from],
        "STOCKAID_ACTION_MAILER_DEFAULT_HOST" => node[:stockaid][:mailer][:default_host]
      }
    end

    def database_password
      File.read(File.join(node[:stockaid][:dir], ".stockaid-db-password")).strip
    end

    def secret_key_base
      File.read(File.join(node[:stockaid][:dir], ".stockaid-secret-key-base"))
    end

    def devise_pepper
      File.read(File.join(node[:stockaid][:dir], ".stockaid-devise-pepper"))
    end

    def google_env
      google_api_env.merge(google_drive_env)
    end

    def google_api_env
      if node[:stockaid][:google][:api_key]
        { "STOCKAID_GOOGLE_API_KEY" => node[:stockaid][:google][:api_key] }
      else
        {}
      end
    end

    def google_drive_env
      if node[:stockaid][:google][:drive_json]
        { "STOCKAID_GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON" => node[:stockaid][:google][:drive_json].to_json }
      else
        {}
      end
    end

    def mailgun_env
      if node[:stockaid][:mailgun][:enabled]
        {
          "STOCKAID_MAILGUN_DOMAIN" => node[:stockaid][:mailgun][:domain],
          "STOCKAID_MAILGUN_API_KEY" => node[:stockaid][:mailgun][:api_key]
        }
      else
        {}
      end
    end

    def newrelic_env
      if node[:stockaid][:newrelic][:enabled]
        {
          "NEW_RELIC_APP_NAME" => node[:stockaid][:newrelic][:app_name],
          "NEW_RELIC_LICENSE_KEY" => node[:stockaid][:newrelic][:license_key]
        }
      else
        {}
      end
    end
  end

  module Helper
    module_function def systemd_env_variable(key, value)
      {
        "\\" => "\\\\",
        "\n" => "\\n"
      }.each do |string, replacement|
        value = value.gsub(string, replacement)
      end

      if value.include?('"') && value.include?("'")
        raise "Please avoid using both ' and \" in an environment variable: #{value.inspect}"
      elsif value.include?('"')
        "Environment='#{key}=#{value}'"
      else
        %(Environment="#{key}=#{value}")
      end
    end

    module_function def stockaid_environment(node)
      StockAid::Environment.new(node).to_h
    end
  end
end

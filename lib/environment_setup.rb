# frozen_string_literal: true
# rubocop:disable Rails/Output

require 'dotenv'
Dotenv.load('.ruby-env')

class EnvironmentSetup
  # Increment this version if you change the setup such that everyone should re-run this
  VERSION = 3
  ENV_FILE = File.expand_path("../../.ruby-env", __FILE__).freeze
  RED = "\e[31m".freeze
  GREEN = "\e[32m".freeze
  BOLD = "\e[1m".freeze
  CLEAR = "\e[0m".freeze

  attr_reader :changed
  alias changed? changed

  def self.setup
    new.setup
  end

  def self.setup?
    # This setup is not meant for production
    return true if Rails.env.production?
    ENV["STOCKAID_ENV_SETUP"] == VERSION.to_s
  end

  def self.check_setup
    unless EnvironmentSetup.setup?
      abort "#{RED}#{BOLD}Your environment is not set up!#{CLEAR}\n" \
            "#{RED}#{BOLD}Please run the following commands:#{CLEAR}\n" \
            "#{RED}$ rake setup#{CLEAR}\n" \
            "#{RED}$ rvm use .#{CLEAR}"
    end
  end

  def setup
    setup_site_name
    setup_secret_key_base
    setup_devise_pepper
    setup_postgres
    setup_google_api_key
    update_env_setup
    check_changed
  end

  private

  def check_changed
    if changed?
      puts "#{GREEN}Your environment is now setup!#{CLEAR}\n" \
           "Please run the following:\n" \
           "$ rvm use ."
    else
      puts "Your environemt is already setup!"
    end
  end

  def setup_site_name
    update "STOCKAID_SITE_NAME", prompt: "What is your site's name?"
  end

  def setup_secret_key_base
    update "STOCKAID_SECRET_KEY_BASE" do
      puts "Generating secret key base"
      require "securerandom"
      SecureRandom.hex 64
    end
  end

  def setup_devise_pepper
    update "STOCKAID_DEVISE_PEPPER" do
      puts "Generating Devise pepper"
      require "securerandom"
      SecureRandom.hex 64
    end
  end

  def setup_google_api_key
    update "STOCKAID_GOOGLE_API_KEY", prompt: "What is your Google API key?"
  end

  def setup_postgres
    update "STOCKAID_DATABASE_USERNAME", prompt: "What is your postgres username?"
    update "STOCKAID_DATABASE_PASSWORD", prompt: "What is your postgres password?"
  end

  def update_env_setup
    update("STOCKAID_ENV_SETUP", force: true) { VERSION }
  end

  def update(env_var, prompt: nil, force: false)
    return if !force && ENV[env_var].present?

    if block_given?
      save_env env_var, yield
    else
      print "#{prompt}\n> "
      save_env env_var, STDIN.gets.strip
    end

    changed!
  end

  def save_env(env_var, value)
    if File.exist? ENV_FILE
      update_env(env_var, value)
    else
      File.write(ENV_FILE, "#{env_var}=#{value}\n")
    end
  end

  def update_env(env_var, value)
    contents = File.read ENV_FILE

    if contents =~ /^#{Regexp.escape env_var}=/
      contents.sub!(/^#{Regexp.escape env_var}=.*$/, "#{env_var}=#{value}")
    else
      contents << "#{env_var}=#{value}\n"
    end

    File.write(ENV_FILE, contents)
  end

  def changed!
    @changed = true
  end
end
# rubocop:enable Rails/Output

# Be sure to restart your server when you modify this file or the environment variable.

Rails.application.config.site_name = ENV["STOCKAID_SITE_NAME"].presence || "StockAid"
Rails.application.config.contact_street_address_line = ENV["STOCKAID_CONTACT_STREET"].presence || "1777 Hamilton Avenue #2280" # rubocop:disable Metrics/LineLength
Rails.application.config.contact_city_line = ENV["STOCKAID_CONTACT_CITY"].presence || "San Jose, CA 95125"
Rails.application.config.contact_phone = ENV["STOCKAID_CONTACT_PHONE"].presence || "408.674.5744"
Rails.application.config.external_site = ENV["STOCKAID_EXTERNAL_SITE"].presence || "http://gratefulgarment.org/"

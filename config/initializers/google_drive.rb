Rails.application.configure do
  config.google_drive = ActiveSupport::OrderedOptions.new
  config.google_drive.service_account_json = ENV["STOCKAID_GOOGLE_DRIVE_SERVICE_ACCOUNT_JSON"]
  config.google_drive.folder = ENV["STOCKAID_GOOGLE_DRIVE_FOLDER"].presence || "StockAid"
end

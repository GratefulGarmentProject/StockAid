if ENV["STOCKAID_GOOGLE_API_KEY"]
  Geocoder.configure(api_key: ENV["STOCKAID_GOOGLE_API_KEY"])
end

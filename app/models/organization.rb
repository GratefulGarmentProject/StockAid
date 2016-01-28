class Organization < ActiveRecord::Base
  has_many :organization_users
  has_many :users, through: :organization_users

  default_scope { order("upper(name)") }

  before_save :add_county_lat_lon

  def add_county_lat_lon
    if changed_attributes.keys.include?("address")
      result = fetch_geocoding_data
      if result
        self.county = result.address_components.find { |component|
          component["types"].include?("administrative_area_level_2")
        }["short_name"]
        self.latitude = result.latitude
        self.longitude = result.longitude
      end
    end
  end

  def fetch_geocoding_data
    begin
      result = Geocoder.search(address).first
    rescue
      Rails.logger.error("Error fetching geocoding info for #{address}")
    end
    result
  end
  private :fetch_geocoding_data
end

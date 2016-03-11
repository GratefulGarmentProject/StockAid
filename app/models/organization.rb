class Organization < ActiveRecord::Base
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :orders

  # default_scope { order("upper(name)") }

  before_save :add_county_lat_lon

  def add_county_lat_lon
    if changed_attributes.keys.include?("address")
      fetch_geocoding_data do |result|
        self.county = result.address_components.find { |component|
          component["types"].include?("administrative_area_level_2")
        }["short_name"]
        self.latitude = result.latitude
        self.longitude = result.longitude
      end
    end
  end

  private def fetch_geocoding_data
    begin
      result = Geocoder.search(address).first
    rescue Geocoder::Error => e
      Rails.logger.error("Error fetching geocoding info for #{address}:\n #{e.backtrace}")
    end
    yield result if result
  end
end

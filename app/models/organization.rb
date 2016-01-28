class Organization < ActiveRecord::Base
  has_many :organization_users
  has_many :users, through: :organization_users

  default_scope { order("upper(name)") }

  before_save :add_county_lat_lon

  def add_county_lat_lon
    if self.changed_attributes.keys.include?("address")
      begin
        result = Geocoder.search(self.address).first
        self.county = result.address_components.find { |component|
          component["types"].include?("administrative_area_level_2")
        }["short_name"]
        self.latitude = result.latitude
        self.longitude = result.longitude
      rescue
        Rails.logger.error("Error fetching geocoding info for #{self.address}")
      end
    end
  end
end

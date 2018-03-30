class BinLocation < ActiveRecord::Base
  has_many :bins

  def self.create_or_find_bin_location(params)
    raise "Missing selected_bin_location param!" unless params[:selected_bin_location].present?
    return BinLocation.find(params[:selected_bin_location]) if params[:selected_bin_location] != "new"
    location_params = params.permit(:rack, :shelf)
    BinLocation.create!(location_params)
  end

  def display
    "Rack #{rack} - Shelf #{shelf}"
  end
end

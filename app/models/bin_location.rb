class BinLocation < ApplicationRecord
  include SoftDeletable

  has_many :bins, -> { not_deleted.order(:label) }

  validates :rack, uniqueness: { scope: :shelf, conditions: -> { not_deleted } }

  def self.create_or_find_bin_location(params)
    raise "Missing selected_bin_location param!" if params[:selected_bin_location].blank?
    return BinLocation.not_deleted.find(params[:selected_bin_location]) if params[:selected_bin_location] != "new"
    location_params = params.permit(:rack, :shelf)
    BinLocation.create!(location_params)
  end

  def deletable?
    bins.empty?
  end

  def display
    if shelf.blank?
      "Rack #{rack}"
    else
      "Rack #{rack} - Shelf #{shelf}"
    end
  end
end

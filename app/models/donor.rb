class Donor < ApplicationRecord
  validates :name, uniqueness: true
  validates :email, uniqueness: true, allow_nil: true
  before_validation { self.email = nil if email.blank? }

  has_many :addresses, through: :donor_addresses

  def self.all_donors
    order(:name).all
  end

  def self.create_or_find_donor(params)
    raise "Missing selected_donor param!" unless params[:selected_donor].present?
    return Donor.find(params[:selected_donor]) if params[:selected_donor] != "new"
    donor_params = params.require(:donor).permit(:name, :address, :email)
    Donor.create!(donor_params)
  end
end

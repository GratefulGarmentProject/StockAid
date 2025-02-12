class County < ApplicationRecord
  ALLOWED_FOR_ALL = "all".freeze
  ALLOWED_FOR_ORGANIZATION = "org".freeze
  ALLOWED_FOR_DONOR = "donor".freeze

  validates :allowed_for, inclusion: { in: [ALLOWED_FOR_ALL, ALLOWED_FOR_ORGANIZATION, ALLOWED_FOR_DONOR] }

  def self.allowed_for_select_options
    [
      ["Anything", ALLOWED_FOR_ALL],
      ["Organizations Only", ALLOWED_FOR_ORGANIZATION],
      ["Donors Only", ALLOWED_FOR_DONOR]
    ]
  end

  def self.for_organizations
    where(allowed_for: [ALLOWED_FOR_ALL, ALLOWED_FOR_ORGANIZATION])
  end

  def self.for_donors
    where(allowed_for: [ALLOWED_FOR_ALL, ALLOWED_FOR_DONOR])
  end

  def self.select_options
    all.order(:name).pluck(:name, :id)
  end

  def allowed_for_label
    case allowed_for
    when ALLOWED_FOR_ALL
      "Anything"
    when ALLOWED_FOR_ORGANIZATION
      "Organizations Only"
    when ALLOWED_FOR_DONOR
      "Donors Only"
    end
  end
end

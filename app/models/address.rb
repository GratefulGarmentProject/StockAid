class Address < ActiveRecord::Base
  belongs_to :organization
  def to_s
    address
  end
end

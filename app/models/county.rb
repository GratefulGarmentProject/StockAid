class County < ApplicationRecord
  def self.select_options
    all.order(:name).pluck(:name, :id)
  end
end

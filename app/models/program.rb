class Program < ApplicationRecord
  def self.alphabetical
    order("LOWER(name)")
  end
end

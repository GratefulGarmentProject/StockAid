class Program < ApplicationRecord
  def self.alphabetical
    order(Arel.sql("LOWER(name)"))
  end
end

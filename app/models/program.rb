class Program < ApplicationRecord
  def self.alphabetical
    order(Arel.sql("LOWER(name)"))
  end

  def initialized_name
    name.gsub(/\b(\w)\w*?\b/, "\\1").gsub(/[\s\-]/, "")
  end
end

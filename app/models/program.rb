class Program < ApplicationRecord
  has_many :program_surveys
  has_many :surveys, through: :program_surveys

  def self.alphabetical
    order(Arel.sql("LOWER(name)"))
  end
end

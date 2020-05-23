class Program < ApplicationRecord
  has_many :program_associations
  has_many :orders, through: :program_associations
  has_many :order_details, through: :program_associations
  has_many :items, through: :program_associations

  validates :name, presence: true
end

class ProgramAssociations < ApplicationRecord
  belongs_to :program
  belongs_to :programable, polymorphic: true
end

class Order < ApplicationRecord
  has_many :program_associations, as: :programable, dependent: :destroy
  has_many :programs, through: :program_associations
end

class OrderDetail < ApplicationRecord
  has_many :program_associations, as: :programable, dependent: :destroy
  has_many :programs, through: :program_associations
end

class Item < ApplicationRecord
  has_one :program_association, as: :programable, dependent: :destroy
  has_one :program, as: :programable
end

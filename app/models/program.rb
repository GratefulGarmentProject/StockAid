class Program < ApplicationRecord
  has_many :organization_programs, dependent: :destroy
  has_many :order_programs, dependent: :destroy
  has_many :order_detail_programs, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end

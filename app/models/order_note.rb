class OrderNote < ActiveRecord::Base
  belongs_to :order

  validates :text, presence: true
end

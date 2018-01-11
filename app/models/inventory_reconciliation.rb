class InventoryReconciliation < ActiveRecord::Base
  belongs_to :user
  has_many :reconciliation_notes
  has_many :reconciliation_unchanged_items

  def items(params)
    @items ||= Item.includes(:category).for_category(params[:category_id])
  end

  def full_title
    "#{title} - #{display_created_at}"
  end

  def display_created_at
    created_at.strftime("%b-%d-%Y")
  end
end

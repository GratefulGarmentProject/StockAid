require "set"

class InventoryReconciliation < ActiveRecord::Base
  belongs_to :user
  has_many :reconciliation_notes
  has_many :reconciliation_unchanged_items

  def items(params)
    @items ||= Item.includes(:category).with_requested_quantity.for_category(params[:category_id])
  end

  def full_title
    "#{title} - #{display_created_at}"
  end

  def display_created_at
    created_at.strftime("%b-%d-%Y")
  end

  def reconcile(user, item, new_amount)
    if item.current_quantity == new_amount
      mark_reconciled(user, item)
    else
      raise "TODO"
    end
  end

  def reconciled_items_set
    @reconciled_items_set ||=
      Set.new.tap do |result|
        reconciliation_unchanged_items.includes(:item).each { |x| result << x.item }
        # TODO: Include items that have had a new amount set
      end
  end

  def reconciled?(item)
    reconciled_items_set.include?(item)
  end

  def mark_reconciled(user, item)
    return if reconciled?(item)
    reconciliation_unchanged_items.create!(user: user, item: item)
  end
end

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
      item.mark_event edit_amount: new_amount, edit_method: "new_total", edit_reason: "reconciliation", edit_source: paper_trail_edit_source
      item.save!
    end
  end

  def paper_trail_edit_source
    "Reconciliation ##{id}"
  end

  def updated_item_versions
    @updated_items ||= Item.paper_trail_version_class.includes(:item).where(edit_source: paper_trail_edit_source).to_a
  end

  def reconciled_items_set
    @reconciled_items_set ||=
      Set.new.tap do |result|
        reconciliation_unchanged_items.includes(:item).each { |x| result << x.item }
        updated_item_versions.each { |x| result << x.item }
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

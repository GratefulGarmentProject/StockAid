class AddIgnoredBinsToInventoryReconciliation < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_reconciliations, :ignored_bin_ids, :int, array: true, default: []
  end
end

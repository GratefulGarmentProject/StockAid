class ReconciliationUnchangedItem < ApplicationRecord
  belongs_to :inventory_reconciliation
  belongs_to :user
  belongs_to :item
end

class ReconciliationNote < ApplicationRecord
  belongs_to :user
  belongs_to :inventory_reconciliation
end

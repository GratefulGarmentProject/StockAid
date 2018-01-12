class ReconciliationNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :inventory_reconciliation
end

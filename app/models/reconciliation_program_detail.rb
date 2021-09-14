class ReconciliationProgramDetail < ApplicationRecord
  belongs_to :inventory_reconciliation
  belongs_to :program
end

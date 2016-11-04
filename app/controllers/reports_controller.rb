class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?

  def value_by_donor
    @report = Reports::ValueByDonor.new(params)
  end

  def value_by_county
    @report = Reports::ValueByCounty.new(params)
  end

  def total_inventory_value
    @report = Reports::TotalInventoryValue.new(params)
  end
end

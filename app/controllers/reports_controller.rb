class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?

  def value_by_county
    @org_by_county = Organization.value_by_county_report
  end

  def total_inventory_value
    @report = Reports::TotalInventoryValue.new(params)
  end
end

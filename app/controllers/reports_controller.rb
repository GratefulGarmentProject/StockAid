class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?

  def value_by_county
    @org_by_county = Organization.value_by_county_report
  end

  def total_inventory_value
    @category = Category.find(params[:category_id]) if params[:category_id]
  end
end

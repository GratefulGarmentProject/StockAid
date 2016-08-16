class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?

  def index
    # raise params.inspect
    @report = params[:report]
    if @report == "value_by_county"
      @org_by_county = Organization.by_county_report
    elsif @report == "total_inventory_value"
      @category = Category.find(params[:category_id]) if params[:category_id]
      @categories = Category.all
    end
  end
end

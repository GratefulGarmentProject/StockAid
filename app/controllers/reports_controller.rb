class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?
  before_action :store_filters

  def value_by_donor
    @report = Reports::ValueByDonor.new(params, session)
  end

  def value_by_county
    @report = Reports::ValueByCounty.new(params, session)
  end

  def total_inventory_value
    @report = Reports::TotalInventoryValue.new(params, session)
  end

  private

  def store_filters
    [:report_start_date, :report_end_date].each do |key|
      session[key] = params[key] if params.include?(key)
    end
  end
end

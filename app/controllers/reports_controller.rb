class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?

  def index
    @org_by_county = {}
    Organization.counties.sort_by { |county| (county.presence || "no county").downcase }.each do |county_name|
      @org_by_county[county_name.presence || "No County"] = Organization.where(county: county_name)
    end
  end
end

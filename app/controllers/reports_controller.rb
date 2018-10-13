class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?, except: [:export_donors, :export_organizations]
  require_permission :can_view_donations?, only: [:export_donors]
  require_permission :can_create_organization?, only: [:export_organizations]
  before_action :store_filters

  def export_donors
    send_data Reports::ExportDonors.new.to_csv, filename: "donors-#{Time.zone.today}.csv"
  end

  def export_organizations
    send_data Reports::ExportOrganizations.new.to_csv, filename: "organizations-#{Time.zone.today}.csv"
  end

  def value_by_donor
    @report = Reports::ValueByDonor.new(params, session)
  end

  def value_by_county
    @report = Reports::ValueByCounty.new(params, session)
  end

  def total_inventory_value
    params[:date] ||= Time.zone.now.strftime("%m/%d/%Y")
    @report = Reports::TotalInventoryValue.new(params, session)
  end

  def graphs
    @graphs = Reports::Graphs.new
  end

  private

  def store_filters
    [:report_start_date, :report_end_date].each do |key|
      session[key] = params[key] if params.include?(key)
    end
  end
end

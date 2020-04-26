class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?
  before_action :store_filters

  def graphs
    @graphs = Reports::Graphs.new
  end

  def inventory_adjustments
    params[:start_date] ||= 1.month.ago.strftime("%m/%d/%Y")
    params[:end_date] ||= Time.zone.now.strftime("%m/%d/%Y")
    @report = Reports::InventoryAdjustments.new(params, session)
  end

  def net_suite_export
    if net_suite_params[:donation].present?
      return unless current_user.can_view_donations?
      send_csv Reports::NetSuite::DonationExport.new, filename: "net-suite-donations-#{Time.zone.today}.csv"
    elsif net_suite_params[:donors].present?
      return unless current_user.can_view_donations?
      send_csv Reports::NetSuite::DonorExport.new, filename: "net-suite-donors-#{Time.zone.today}.csv"
    elsif net_suite_params[:orders].present?
      send_csv Reports::NetSuite::OrderExport.new, filename: "net-suite-orders-#{Time.zone.today}.csv"
    elsif net_suite_params[:organizations].present?
      return unless current_user.can_create_organization?
      send_csv Reports::NetSuite::OrganizationExport.new, filename: "net-suite-organizations-#{Time.zone.today}.csv"\
    end

    redirect_to integrations_path
  end

  def total_inventory_value
    params[:date] ||= Time.zone.now.strftime("%m/%d/%Y")
    @report = Reports::TotalInventoryValue.new(params, session)
  end

  def value_by_donor
    @report = Reports::ValueByDonor.new(params, session)
  end

  def value_by_county
    @report = Reports::ValueByCounty.new(params, session)
  end

  private

  def store_filters
    [:report_start_date, :report_end_date].each do |key|
      session[key] = params[key] if params.include?(key)
    end
  end

  def net_suite_params
    params.permit(:donations, :donors, :orders, :organizations)
  end
end

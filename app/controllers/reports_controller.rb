class ReportsController < ApplicationController
  active_tab "reports"

  require_permission :can_view_reports?
  before_action :store_filters

  def donor_receipts
    if params[:donor_ids].present?
      @receipts = Reports::DonorReceipts.new(params, session).receipts
      render layout: "blank_print"
    elsif params[:report_start_date].present? && params[:report_end_date].present?
      @donors = Reports::DonorReceipts.new(params, session).donors
    end
  end

  def graphs
    @graphs = Reports::Graphs.new
  end

  def inventory_adjustments
    params[:start_date] ||= 1.month.ago.strftime("%m/%d/%Y")
    params[:end_date] ||= Time.zone.now.strftime("%m/%d/%Y")
    @report = Reports::InventoryAdjustments.new(params, session)

    if params[:csv].present?
      send_csv @report, filename: @report.csv_filename
    end
  end

  def net_suite_export
    if report_exporter&.records_present?
      send_csv report_exporter, filename: "net-suite-#{net_suite_params[:report_type]}-#{Time.zone.today}.csv"
    else
      redirect_to integrations_path(net_suite_params), flash: {
        notice: "No records present for this report with these filters"
      }
    end
  end

  def total_inventory_value
    params[:date] ||= Time.zone.now.strftime("%m/%d/%Y")
    @report = Reports::TotalInventoryValue.new(params, session)

    if params[:csv].present?
      send_csv @report, filename: @report.csv_filename
    end
  end

  def value_by_donor
    @report = Reports::ValueByDonor.new(params, session)
  end

  def value_by_county
    @report = Reports::ValueByCounty.new(params, session)
  end

  def price_point_variance
    @report = Reports::PricePointVariance.new(params, session)
  end

  private

  def report_exporter
    @report_exporter ||=
      Reports::NetSuite::BaseExport.new(current_user, net_suite_params[:report_type], session).build
  end

  def store_filters
    %i[report_start_date report_end_date].each do |key|
      session[key] = params[key] if params.include?(key)
    end
  end

  def net_suite_params
    params.permit(:report_type, :report_start_date, :report_end_date)
  end
end

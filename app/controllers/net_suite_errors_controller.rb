class NetSuiteErrorsController < ApplicationController
  require_permission :can_view_integrations?

  def index
    @errors = FailedNetSuiteExport.order(created_at: :desc).to_a
  end

  def show
    @error = FailedNetSuiteExport.find(params[:id])
  end

  def destroy
    error = FailedNetSuiteExport.find(params[:id])
    error.destroy!
    redirect_to net_suite_errors_path, flash: { success: "NetSuite error deleted!" }
  end
end

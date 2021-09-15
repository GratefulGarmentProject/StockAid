class VendorsController < ApplicationController
  require_permission :can_view_vendors?, only: %i[index edit]
  require_permission :can_create_vendors?, only: %i[new create netsuite_import update]
  require_permission :can_delete_and_restore_vendors?, only: %i[destroy deleted restore]
  require_permission one_of: %i[can_create_vendors? can_update_vendors?], except: %i[new create netsuite_import]

  active_tab "vendors"

  before_action :set_vendor, only: %i[edit update destroy restore]

  def index
    @vendors = Vendor.all
  end

  def new
    @vendor = Vendor.new
  end

  def edit
    @redirect_to = Redirect.to(vendors_path, params, allow: [:vendor])
  end

  def update
    if @vendor.update!(vendor_params)
      redirect_to vendors_path
    else
      redirect_to vendors_path(@vendor)
    end
  end

  def netsuite_import
    vendor = NetSuiteIntegration::VendorImporter.new(params).import
    redirect_to edit_vendor_path(vendor)
  rescue ActiveRecord::RecordInvalid => e
    @show_tab = "netsuite-import"
    @vendor = e.record
    flash.now[:error] = e.message
    render :new
  end

  def create
    save_and_export = params[:save_and_export_vendor] == "true"
    vendor = NetSuiteIntegration::VendorExporter.create_and_export(vendor_params, save_and_export)
    flash[:success] = "Vendor '#{vendor.name}' created!"
    redirect_to vendors_path
  rescue ActiveRecord::RecordInvalid => e
    @vendor = e.record
    flash.now[:error] = e.message
    render :new
  end

  def destroy
    begin
      @vendor.soft_delete
      flash[:success] = "Vendor '#{@vendor.name}' deleted!"
    rescue DeletionError => e
      flash[:error] = e.message
    rescue
      flash[:error] = <<-eos
        We were unable to delete the vendor as requested.
        Please try again or contact a system administrator.
      eos
    end

    redirect_to vendors_path
  end

  def deleted
    @vendors = Vendor.deleted
  end

  def restore
    @vendor.restore

    redirect_to vendors_path(@vendor)
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:id])
  end

  def vendor_params
    vendor_params = params.require(:vendor)

    vendor_params[:addresses_attributes].select! do |_, h|
      h[:address].present? || %i[street_address city state zip].all? { |k| h[k].present? }
    end

    vendor_params.permit(:name, :phone_number, :website, :email, :contact_name, :external_id, :external_type,
                         addresses_attributes: %i[address street_address city state zip id])
  end
end

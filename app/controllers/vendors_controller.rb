class VendorsController < ApplicationController
  require_permission :can_view_vendors?, only: [:index, :edit]
  require_permission :can_create_vendors?, only: [:new, :create]
  require_permission :can_delete_and_restore_vendors?, only: [:destroy, :deleted, :restore]
  require_permission one_of: [:can_create_vendors?, :can_update_vendors?], except: [:new, :create]

  active_tab "vendors"

  before_action :set_vendor, only: [:edit, :update, :destroy, :restore]

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

  def create
    current_user.create_vendor params
    redirect_to vendors_path
  rescue ActiveRecord::RecordInvalid => e
    @vendor = e.record
    flash[:error] = e.message
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
    vendor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
    vendor_params.permit(:name, :phone_number, :website, :email, :contact_name,
                         addresses_attributes: [:address, :id])
  end
end

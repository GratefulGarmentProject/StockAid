class VendorsController < ApplicationController
  require_permission :can_view_vendors?, only: %i[index edit]
  require_permission :can_create_vendors?, only: %i[new create]
  require_permission :can_delete_and_restore_vendors?, only: %i[destroy deleted restore]
  require_permission one_of: %i[can_create_vendors? can_update_vendors?], except: %i[new create]

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

  def create
    @vendor = Vendor.new(vendor_params)
    if @vendor.save
      flash[:success] = "Vendor '#{@vendor.name}' created!"
      redirect_to vendors_path
    else
      flash[:error] = "#{@vendor.errors.full_messages.join('. ')}.  Please try again."
      render :new
    end
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
                         addresses_attributes: %i[address id])
  end
end

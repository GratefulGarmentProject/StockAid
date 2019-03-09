class VendorsController < ApplicationController
  require_permission :can_view_vendors?, only: [:index, :edit]
  require_permission :can_create_vendors?, only: [:new, :create]
  require_permission :can_delete_and_restore_vendors?, only: [:destroy, :deleted, :restore]
  require_permission one_of: [:can_create_vendors?, :can_update_vendors?], except: [:new, :create]
  active_tab "vendors"

  def index
    @vendors = Vendor.all
  end

  def new
    @vendor = Vendor.new
  end

  def edit
    @redirect_to = Redirect.to(vendors_path, params, allow: [:vendor])
    @vendor = Vendor.find params[:id]
  end

  def update
    current_user.update_vendor params
    redirect_to vendors_path
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
    @vendor = Vendor.find params[:id]

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
    @vendor = Vendor.find_deleted params[:id]
    @vendor.restore

    redirect_to vendors_path(@vendor)
  end
end

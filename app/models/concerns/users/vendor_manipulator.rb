module Users
  module VendorManipulator
    extend ActiveSupport::Concern

    def can_create_vendors?
      super_admin?
    end

    def can_update_vendors?
      super_admin?
    end

    def can_view_vendors?
      super_admin?
    end

    def can_delete_and_restore_vendors?
      super_admin?
    end

    def create_vendor(params)
      raise PermissionError unless can_create_vendors?
      Vendor.create! Vendor.permitted_vendor_params(params)
    end

    def update_vendor(params)
      raise PermissionError unless can_update_vendors?
      vendor = Vendor.includes(:addresses).find(params[:id])
      vendor.update! Vendor.permitted_vendor_params(params)
    end
  end
end

module VendorsHelper
  def save_vendor_path
    Redirect.to(vendors_path, params, allow: [:new_purchase])
  end

  def cancel_edit_vendor_path
    Redirect.to(vendors_path, params, allow: [:vendor, :vendors])
  end

  def cancel_new_vendor_path
    Redirect.to(vendors_path, params, allow: [:vendors, :new_purchase])
  end
end

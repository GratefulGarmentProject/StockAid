module VendorsHelper
  def cancel_edit_vendor_path
    Redirect.to(vendors_path, params, allow: [:vendor, :vendors])
  end
end

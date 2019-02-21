module DonorsHelper
  def cancel_edit_donor_path
    Redirect.to(donors_path, params, allow: [:order, :users])
  end
end

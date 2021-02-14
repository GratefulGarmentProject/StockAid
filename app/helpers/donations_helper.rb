module DonationsHelper
  def sync_donation_button(donation)
    css_class = "btn btn-primary"

    css_class += " disabled" unless donation.donor.synced?

    button = link_to "Sync to NetSuite",
                     sync_donation_path(donation),
                     class: css_class,
                     data: { toggle: "tooltip" },
                     method: :post

    if donation.donor.synced?
      button
    else
      disabled_title_wrapper("Please sync the donor to be able to sync to NetSuite.") { button }
    end
  end
end

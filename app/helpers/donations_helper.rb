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

  def close_donation_button(donation)
    css_class = "btn btn-primary"
    enabled = donation.donor.synced? && donation.revenue_stream&.synced?

    css_class += " disabled" unless enabled

    button = link_to "Close",
                     close_donation_path(donation),
                     class: css_class,
                     data: { toggle: "tooltip" },
                     method: :post

    if enabled
      button
    else
      message = []
      message << "sync the donor to NetSuite" unless donation.donor.synced?
      message << "set up the external ID for the revenue stream" unless donation.revenue_stream&.synced?
      message = message.join(" and ")
      disabled_title_wrapper("To be able to close this donation, please #{message}.") { button }
    end
  end
end
